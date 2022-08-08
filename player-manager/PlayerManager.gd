extends Spatial
# player_list or map


var _selfplayer_id : String = ""
var _player_dict = {}   # uid to player, key是uid，value是Player.tscn
var _player_resource : Resource
var _isResetPos = false #是否重置初始位置
var _isSpeak = false # 人物是否在说话
var _stopSpeakTimer = null

func _ready():
	if(NavigatorTool.singleGameType):
		yield(get_tree().create_timer(0.5),"timeout")
		createSingleGamePlayer()
		pass
	pass

func _enter_tree():
	_selfplayer_id = NavigatorTool.selfUserData.userId
	SignalBus.connect("network_websocket_pb_enter", self, "_join_room")
	SignalBus.connect("network_websocket_pb_leave", self, "_leave_room")
	SignalBus.connect("network_websocket_pb_frame", self, "_handle_frame")
	SignalBus.connect("network_websocket_pb_state", self, "_handle_state")
	SignalBus.connect("input_joystick", self, "_handle_input_joystick")
	SignalBus.connect("input_state", self, "_handle_input_state")
	SignalBus.connect("input_resume_position", self, "_on_resume_position_message")
	SignalBus.connect("scene_users_volumes", self, "_on_scene_users_volumes")
	SignalBus.connect("input_signal_touch_not_pressed", self, "_on_input_signal_touch_not_pressed")
	SignalBus.connect("player_action_end", self, "_on_player_action_end")
	
	_player_resource = preload("res://player-manager/player/Player.tscn")
	if _player_resource == null:
		print("load player resource fail")
	
func _send_frame():
	pass
	
func _send_state():
	pass

func _handle_input_joystick(type ,direction,input):
	var msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
	msgjson["type"] = type
	msgjson["curForward"] = direction
	_handle_input_state(msgjson)
	
func _handle_input_state(msgjson):
	if not _player_dict.has(_selfplayer_id):
		return
	if not "curPosition" in msgjson or msgjson["curPosition"] == null:
		msgjson["curPosition"] = _player_dict[_selfplayer_id].global_transform.origin
	_handle_input(msgjson)
	
func signal_stop_or_move(input_type):
	# 摇杆stop/move回调
	if input_type != state and input_type == GlobalPlayer.State.STOP:
		SignalBus.emit_signal("input_stop")
	if input_type != state and input_type == GlobalPlayer.State.MOVE:
		SignalBus.emit_signal("input_move")
	state = input_type
		
var state = GlobalPlayer.State.STOP
func _handle_input(msgjson):
	if not _player_dict.has(_selfplayer_id):
		return
	var input_type = msgjson["type"]
	# 遥感stop/move状态转换，取不到则不接受遥感数据
	if input_type == GlobalPlayer.State.STOP:
		var stop_state = player(_selfplayer_id).get_stop_state()
		if not stop_state:
			signal_stop_or_move(input_type)
			return
		msgjson["type"] = stop_state
	elif input_type == GlobalPlayer.State.MOVE:
		var move_state = player(_selfplayer_id).get_move_state()
		if not move_state:
			signal_stop_or_move(input_type)
			return
		msgjson["type"] = move_state
	msgjson["curForward"] = msgjson["curForward"].normalized()	
	msgjson["curForward"] = GlobalPlayer.vec3DiviTrans(GlobalPlayer.vec3MultiTrans(msgjson["curForward"]))
	msgjson["curForward"].y = 0
	msgjson["curPosition"] = GlobalPlayer.vec3DiviTrans(GlobalPlayer.vec3MultiTrans(msgjson["curPosition"]))
	if NavigatorTool.pacmanNetworkModel == true:  	
		_player_dict[_selfplayer_id]._sendMoveMessage(msgjson["type"], msgjson["delta"], msgjson["curPosition"], msgjson["curPosition"], msgjson["curForward"], msgjson["curForward"], msgjson["targetId"])
	else:	
		if msgjson["type"] in [GlobalPlayer.State.WALK, GlobalPlayer.State.CREEP]:#处理4遍
			for i in range(4):	
				_player_dict[_selfplayer_id]._addMoveMessage(msgjson)
		else:	
			_player_dict[_selfplayer_id]._addMoveMessage(msgjson)
		_player_dict[_selfplayer_id]._sendMoveMessage(msgjson["type"], msgjson["delta"], msgjson["curPosition"], msgjson["curPosition"], msgjson["curForward"], msgjson["curForward"], msgjson["targetId"])		
	signal_stop_or_move(input_type)
	
# 人物瞬移
func _on_resume_position_message(curPosition, curForward):
	var msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
	msgjson["type"] = GlobalPlayer.State.STOP
	msgjson["curForward"] = curForward
	msgjson["curPosition"] = curPosition
	_handle_input_state(msgjson)


func _handle_frame(frame_data):
	if not _player_dict.has(frame_data.userId):
		return
	
#	print(frame_data)
	if frame_data.userId == _selfplayer_id and NavigatorTool.pacmanNetworkModel == false:
		return
	
	var msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
	msgjson["type"] = frame_data.targetAction
	msgjson["delta"] = GlobalPlayer.intDiviTrans(frame_data.deltaTime)
	msgjson["curPosition"] = GlobalPlayer.vec3DiviTrans(frame_data.curPosition)
	msgjson["curForward"] = GlobalPlayer.vec3DiviTrans(frame_data.curForward)
	msgjson["nextForward"] = GlobalPlayer.vec3DiviTrans(frame_data.nextForward)
	msgjson["targetId"] = frame_data.targetId
	if msgjson["type"] in [GlobalPlayer.State.WALK, GlobalPlayer.State.CREEP]:#处理4遍
		for i in range(4):
			var msgjson2 = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
			msgjson2["type"] = msgjson["type"]
			msgjson2["delta"] = msgjson["delta"]
			msgjson2["curPosition"] = msgjson["curPosition"] + msgjson["curForward"]*msgjson["delta"]*_player_dict[frame_data.userId].playerinfo._move_speed*(i+1)
			msgjson2["curForward"] = msgjson["curForward"] 
			msgjson2["nextForward"] = msgjson["nextForward"]
			msgjson2["targetId"] = msgjson["targetId"]
			_player_dict[frame_data.userId]._addMoveMessage(msgjson2)
	else:
		_player_dict[frame_data.userId]._addMoveMessage(msgjson)
	pass

func _handle_state(state):
	pass

func _leave_room(leaveData):
	print("leave room message")
	SignalBus.emit_signal("playermanager_exit", leaveData)
	if _player_dict.has(leaveData.userId):
		var leavePlayer = _player_dict[leaveData.userId]
		self.remove_child(leavePlayer)
		leavePlayer.exit()
		_player_dict.erase(leaveData.userId)
		leavePlayer.queue_free()
	else:
		print("no match leave user")

func _join_room(user_array : Array):
	print("join room message:")
	if user_array == null:
		print("user array = null")
		return
	if user_array.empty():
		print("user array empty")
	for user_info in user_array:
		if _player_dict.has(user_info.userId):
			print(user_info.userId, " has already exit")
		else:
			var player = _player_resource.instance()
			self.add_child(player)	
			var curPosition = user_info.userPositionInfo.curPosition
			if(abs(curPosition.x)>100 or abs(curPosition.z)>100):
				curPosition = GlobalPlayer.vec3DiviTrans(curPosition)
				pass
			player.transform.origin = curPosition
			player.look_at(user_info.userPositionInfo.curForward, Vector3.UP)
			_player_dict[user_info.userId] = player
			player.init(user_info)
			if user_info.userId == _selfplayer_id:
				player._set_selfplayer(true)
			if !(_isResetPos and user_info.userId == _selfplayer_id):
				# init player state
				var msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
				msgjson["curPosition"] = curPosition
				msgjson["type"] = user_info.userPositionInfo.currentState
				player._addMoveMessage(msgjson)
				print("enter room state:   ",msgjson)
					
				# init player action
				msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
				msgjson["type"] = user_info.userPositionInfo.currentAction
				msgjson["targetId"] = user_info.userPositionInfo.targetId
				msgjson["curPosition"] = player.transform.origin
				player._addMoveMessage(msgjson)
				print("enter room action:   ",msgjson)
			# signal for scene
			SignalBus.emit_signal("playermanager_enter", user_info)

func _setSelfPlayerId(id):
	_selfplayer_id = id

func init():
	pass

func exit():
	for player in _player_dict:
		player.exit()
	_player_dict.clear()

# 根据用户id获取用户
func player(id):
	if _player_dict.has(id):
		return _player_dict[id]
	else:
		SkyBridge.printLog("can not find player {id}\n".format({ 
			"id": id,
		}))
		return null

# 获取当前用户
func currentPlayer():
	if _player_dict.has(_selfplayer_id):
		return _player_dict[_selfplayer_id]
	else:
		return null

# 场景内 用户音量变化
func _on_scene_users_volumes(userVolumes):
	if userVolumes == null or userVolumes.empty():
		return
	var userIdsArray = userVolumes.keys()
	for userId in userIdsArray:
		if not _player_dict.has(userId):
			continue
		var player = _player_dict[userId]
		var volumeAni = player.volumeAni
		if int(userVolumes[userId]) > 0:
			volumeAni.visible = true
			player.setPalyerTextMeshVisible(false)
		else:
			volumeAni.visible = false
			player.setPalyerTextMeshVisible(true)
			
		if userId == NavigatorTool.selfUserData.userId and int(userVolumes[userId]) > 0:
			if self._isSpeak:
				return
			var msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
			msgjson["type"] = GlobalPlayer.Action.SPEAK
			SignalBus.emit_signal("input_state", msgjson)
			SkyBridge.printLog("input_state---------------Speak")
			self._isSpeak = true
			_stopSpeakTimer = Timer.new()
			_stopSpeakTimer.one_shot = true
			_stopSpeakTimer.autostart = true
			_stopSpeakTimer.wait_time = 6.0
			_stopSpeakTimer.connect("timeout", self, "_stopSpeakTimer")
			add_child(_stopSpeakTimer)
	pass
	
func _stopSpeakTimer():
	self._isSpeak = false
	self._stopSpeakTimer = null
	pass
#单机创建一个人物
func createSingleGamePlayer():
	var player = _player_resource.instance()
	self.add_child(player)
	player.transform.origin = Vector3(2,0,2)
	player.look_at(Vector3(0,0,0), Vector3.UP)
	var user_info = {}
	user_info.userId=NavigatorTool.selfUserData.userId
	user_info.userName="单机测试"
	user_info.isRobotAccount = "2"
	user_info.userPositionInfo = {}
	user_info.userPositionInfo.curPosition = Vector3(20,0,20)
	user_info.userPositionInfo.currentState = GlobalPlayer.State.IDLE
	player.init(user_info)
	_player_dict[user_info.userId] = player
	player._set_selfplayer(true)
	SignalBus.emit_signal("playermanager_enter",user_info)
	pass

##########射线检测#####################
#点击人物
const ray_length = 1000
#func _unhandled_input(event):
func _on_input_signal_touch_not_pressed(event):
	var camera = NavigatorTool.globleCamera
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * ray_length
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from,to,[],2)
	if(result.empty()):
		return
	for key in result:
		if key == "collider" and "player" in result[key].to_string():
			var uid: String = result[key].get_node("Info")._userId
			if uid == null or uid.empty():
				return
			if uid == SkyBridge.getUserId():  # 点击了自己
				return
#				SkyBridge.printLog(str("clickPlayer=userId: ", uid))
#				SkyBridge.sendMessage(to_json({
#					"type": "CharacterInfo",
#					"params": {"userId": uid}
#				}))
			SignalBus.emit_signal("open_player_info_card", uid)

func get_user_id_list():
	return _player_dict.keys()

# 用于动作结束后同步所有
func _on_player_action_end(userId, actionInfo):
	if userId == _selfplayer_id:
		player(userId)._addMessageForDisableAction()
