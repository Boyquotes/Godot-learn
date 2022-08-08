class_name Player
extends KinematicBody

# 人物碰撞
signal player_collison(object)


var _moveMessageArray = []
var _curPosition = Vector3.ZERO
var _deltaTime = float(0)
var _move_direction = Vector3.ZERO
var txtLen = 0
var _physicsNum = 0
onready var playerNamePoint:Spatial = $playerNamePoint
onready var particles = $Particles
onready var volumeAni = $MicVolumeAni
#onready var palyerTextMesh = $palyerTextMesh
onready var palyerTextViewport = $palyerTextViewport
onready var ninePatchRect = $palyerTextViewport/NinePatchRect
onready var palyerTextLabel = $palyerTextViewport/NinePatchRect/palyerTextLabel

onready var playerNameMesh = $palyerNameMesh

#onready var playerName:Label = $playerNameBg/playerName
var _curForward = Vector3.ZERO

var _mutex  = Mutex.new()
var playerNameBgLength = 200

var _extra_model

var playerinfo
var flatType = GlobalPlayer.State.FLAT_01

func _ready():
	SignalBus.connect("player_head_text_change",self,"_on_player_head_text_change")
	pass

func init(data):
	playerinfo = get_node("Info")
	playerinfo._userId = data.userId
	playerinfo._userName = data.userName
	playerinfo._isAbleRun = false
	playerinfo._isAbleMove = true
	playerinfo._isAbleWalk = false
	playerinfo._isAbleIdle = false
	playerinfo._isAbleJump = false
	playerinfo._isAbleSit = false
	playerinfo._isRobotAccount = data.isRobotAccount
	
	_set_user_model(data)
	setPlayerName(data.userName)
	pass

var dataxx: NTUserModelInfo = null

func testDd():
	_set_user_model(dataxx)
	pass

# 设置用户数据模型
func _set_user_model(data: NTUserModelInfo):
	self.dataxx = data
	if(data == null):
		return
	if data.modelType == 2:  # 1.个人套装
		$Model.setUserGlb(data.modelURL)
		return

	# 2.官方人物模型数据
	for cell in data.userModels: # 获取用户的组件信息。是个数组
		$Model.setUserModels(cell)
		pass
	pass


# 替换 player的 skeleton 和 animation
# 如果值不为空，就不会替换
func change_player_skeleton(skeleton: Node, animation: Node):
	$Model.change_player_skeleton(skeleton, animation)
	pass


# 给一个人物模型，改变现有人物模型
# 参数 modelNode 人物的模型，必须包含 Armature 节点
# 参数 include_animation 是否包含 AnimationPlayer 节点
# 返回值： 是否替换成功
func change_player_model(modelNode: Node, include_animation: bool) -> bool:
	return $Model.change_player_model(modelNode, include_animation)
	pass

# 显示新的任务模型，并隐藏现有的
func change_player(playerModel: Node):
	if playerModel == null:
		return
	$Model.visible = false
	add_child(playerModel)
	pass
		
func enableProp(bone_name, propFile):
	return $Model.enablePropFromFile(bone_name, propFile)
	
func disableProp(bone_name, propFile):
	return $Model.disablePropFromFile(bone_name, propFile)
		
func enableEffect(bone_name, effectFile):
	return $Model.enablePropFromFile(bone_name, effectFile)
	
func disableEffect(bone_name, effectFile):
	return $Model.disablePropFromFile(bone_name, effectFile)

# 加上鬼头套， true显示鬼头套  false不显示鬼头套
func showYamaHat(yama: bool):
	$Model.showYamaHat(yama)
	pass


func _set_selfplayer(flag):
	get_node("Info")._isSelfPlayer = flag 

func exit(): 
	pass
	
func _addMoveMessage(msg_json):
#	moveMessageArray.append(msg_json)
	_mutex.lock()
#	_deltaTime = msg_json["delta"]
#	_curForward = msg_json["curForward"]
#	_curPosition = msg_json["curPosition"]
	_moveMessageArray.append(msg_json)
#	print("SSSSSSSSSSSSSSSSSS====================    ",_moveMessageArray.size())
	_mutex.unlock()
	
func _addMessageForDisableAction():
	_mutex.lock()
	for msg in _moveMessageArray:
		var type = msg["type"]
		if $MixStateManager.model.inProcessType(type) or $StateManager/OneShot.model.inProcessType(type):
			_mutex.unlock()
			return
	var msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
	msgjson["type"] = GlobalPlayer.Action.DISABLE
	SignalBus.emit_signal("input_state", msgjson)
	_mutex.unlock()
	
	
func _getCurPosition():
	return _curPosition
	
func _getCurForward():
	return _curForward
	
func _getMoveMessage():
	var data = null
	if _mutex.try_lock() == OK:
		data = _moveMessageArray.pop_front()
		_mutex.unlock()
	return data

func _sendMoveMessage(targetAction:int, deltaTime:float, curPosition:Vector3, nextPosition:Vector3, curForward:Vector3, nextForward:Vector3, targetId:String):
	var data = NTFrame.new()
	var n = GlobalPlayer.FIXEDNUM
	data.userId = get_node("Info")._userId
	data.targetId = targetId
	data.targetAction = targetAction
	data.deltaTime = GlobalPlayer.floatMultiTrans(deltaTime)
	data.curPosition = GlobalPlayer.vec3MultiTrans(curPosition)
	data.nextPosition = GlobalPlayer.vec3MultiTrans(nextPosition)
	data.curForward = GlobalPlayer.vec3MultiTrans(curForward)
	data.nextForward = GlobalPlayer.vec3MultiTrans(nextForward)
	SignalBus.emit_signal("network_websocket_send_frame", data)

func _process(delta):
	if(NavigatorTool.globleCamera):
		var pos = playerNamePoint.global_transform.origin
		var screen_pos = NavigatorTool.globleCamera.unproject_position(pos)
		var aimPos = Vector2(screen_pos.x-(playerNameBgLength*0.5),screen_pos.y)
#		$playerNameBg.set_position($playerNameBg.get_position().linear_interpolate(aimPos, 0.5))
		if((aimPos - $playerNameBg.get_position()).length()>20):
			$playerNameBg.set_position(aimPos)
		pass
	pass
	
func setPlayerName(name):
#	var name = "naoteng你好"
	if(name.length()>=8):
		name = name.left(8)
	$playerNameBg/playerName.text = name
	playerNameBgLength = getNameLength(name)
	$playerNameBg.set_size(Vector2((playerNameBgLength),50))

#	var palyerNameMesh:MeshInstance = $palyerNameMesh
#	var palyerNameViewport:Viewport = $palyerNameViewport
	var palyerNameLabel:Label = $palyerNameViewport/palyerNameLabel
#	yield(get_tree().create_timer(0.1), "timeout")
	palyerNameLabel.text = name
	pass
func getNameLength(name):
	var ChineseNum = 0
	var regex = RegEx.new()# 实例化正则类
	regex.compile("^[\u2E80-\u9FFF]+$")# 设定正则表达式
	for i in range(name.length()):
		var result = regex.search(name[i])
		if result:
			ChineseNum +=1
	return ChineseNum*32 + (name.length()-ChineseNum)*16+100
	pass
func _on_timeout():
	
	pass
func _set_scale(scalefactor : Vector3):
	self.scale = scalefactor

func _set_moveSpeed(movespeedfactor : float):
	$Info._move_speed = $Info._basic_move_speed * movespeedfactor
	
func _set_ableMove(flag):
	$Info._isAbleMove = flag
	
func _set_collection(flag):
	$Info._isAbleCollison = flag
	pass
	
func _set_able_collideplayer(flag):
	if flag:
		set_collision_layer_bit(1, true)
		set_collision_mask_bit(1, true)
	else:
		set_collision_layer_bit(1, false)
		set_collision_mask_bit(1, false)

func _getUserId():
	return $Info._userId

func _getName():
	return $Info._userName
	
func _set_model(path):
	var rs = load(path)
	_extra_model = rs.instance()
	self.add_child(_extra_model)
	get_node("StateManager")._model = _extra_model
	get_node("Model").visible = false
	pass 

func _return_model():
	self.remove_child(_extra_model)
	get_node("StateManager")._model = get_node("Model")
	get_node("Model").visible = true
	_extra_model = null
	pass
	
func _set_runningAni(flag):   # use for pac man
	$Info._isRunningAni = flag
	pass 

func show_particles():
	particles.emitting = true
	particles.visible = true
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = 0.6
	timer.connect("timeout", self, "_hide_particles")
	add_child(timer)

func _hide_particles():
	particles.emitting = false
	particles.visible = false
	

#头顶文字
func setPlayerText(txt):
	txtLen = txt.length()
	if(txtLen>=13):
		txt = txt.left(13)
		txtLen = 13
	palyerTextLabel.text = txt
	palyerTextLabel._set_size(Vector2(txtLen*40,41))
	if(txtLen>0):
		$palyerTextMesh.visible = true
	else:
		$palyerTextMesh.visible = false
	if(txtLen<7):
		palyerTextLabel.set_position(Vector2(10+(7-txtLen)*20,30))		
		ninePatchRect.rect_size.x = 300
#		ninePatchRect.set_position(Vector2(429,0))
	else:
		ninePatchRect.rect_size.x = 37+txtLen*40
		palyerTextLabel.set_position(Vector2(20,30))
#		ninePatchRect.set_position(Vector2(520-txtLen*40,0))
#	print("ninePatchRect.rect_size.x===",ninePatchRect.rect_size.x)
#	print("palyerTextLabel===",palyerTextLabel.get_position(),"   ",palyerTextLabel.get_rect())
	
	palyerTextViewport.size.x = ninePatchRect.rect_size.x
	$palyerTextMesh.mesh.size.x = ninePatchRect.rect_size.x/125
	
	pass

func _on_player_head_text_change(userId,txt):
#	print("userId===",userId,"   txt===",txt)
	if(userId == get_node("Info")._userId):
		setPlayerText(txt)
	pass
func setPalyerTextMeshVisible(isVisible):
	if(txtLen>0 and isVisible):
		$palyerTextMesh.visible = true
	else:
		$palyerTextMesh.visible = false
	pass
	
#根据模型设置player的碰撞
func setPlayerCollisionShape():
#	var playerCollisionShapeResouse = preload("res://player-manager/player/CollisionShapeTest2.tscn")
#	if playerCollisionShapeResouse == null:
#		print("load playerCollisionShapeResouse resource fail")
#	var playerCollisionShape = playerCollisionShapeResouse.instance()
#	self.add_child(playerCollisionShape)
#	playerCollisionShape.translation = Vector3(0,2.5,0)
#	playerCollisionShape.rotation_degrees = Vector3(90,0,0)
	
	pass
	
func _physics_process(delta):
	_physicsNum+=1
	if(_physicsNum>=30 and playerinfo._isRobotAccount == "1"):
		_physicsNum = 0
		sendNPCPosition()
	pass

#上报NPC位置
func sendNPCPosition():
	var ntState = NTState.new()
	ntState.userId = playerinfo._userId 
	ntState.targetAction = "14"
	ntState.curPosition = GlobalPlayer.vec3MultiTrans(self.get_global_transform().origin)
	SignalBus.emit_signal("network_websocket_send_state",ntState)
pass

func setStateAnimation(type, anim):
	$StateManager.setAnimation(type, anim)
	
# 调整名字高度
func setPlayerNameHeight(height):
	playerNameMesh.set_translation(Vector3( 0,height, 0 ))
	pass

func get_stop_state():
	return $StateManager.get_stop_state()
	
func get_move_state():
	return $StateManager.get_move_state()

func setForceStop(flag):
	$Info._forceStop = flag
	
func setFriction(value):
	$Info._friction = value
	
func getCurrentState():
	return $StateManager._currentType
