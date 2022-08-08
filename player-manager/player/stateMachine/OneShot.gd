extends PlayerState

var model
var music
var isPlay = false

func ready():
	model = get_node("AnimationModel")
	music = get_node("ActionMusic")
	for type in model.animation:
		if not "mode" in model.animation[type]:
			stateManager.registerState(type, self)
	
func get_stop_type():
	return stateManager.getCurrentState()
	
func get_move_type():
	return stateManager.getCurrentState()
	
func enter(data_json):
	do_input(data_json)
	
func exit(data_json):
	model.disableOneShotAnimation()
	music.stopMusic()
	stateEnd()
	eSignalEnd()
	isPlay = false
	
func oneShotReturn():
	if not _data_json:
		return
	stateManager.transformState(stateManager.getCurrentState())
	
func eSignalStart():
	var type = _data_json["type"]
	var userId = player.get_node("Info")._userId
	print("oneshot action start: {0} {1}".format([userId, type]))
	SignalBus.emit_signal("player_action_start", userId, _data_json)

func eSignalEnd():
	var type = _data_json["type"]
	var userId = player.get_node("Info")._userId
	print("oneshot action end: {0} {1}".format([userId, type]))
	SignalBus.emit_signal("player_action_end", userId, _data_json)

var del = 0
func process(delta):
	while del < 0.5:
		del += delta
		return

	# oneshot结束后恢复原来状态
	if isPlay and not model.isOneShotPlaying():
		oneShotReturn()
		_data_json = {}

var _data_json = {}

func stateEnd():
	var type = _data_json["type"]
	var targetId = _data_json["targetId"]
	var relativeInfo = model.getRelative(type)
	if targetId and relativeInfo:
		var target:Spatial = playerManger.get_parent().get_node(targetId)
		target.remove_child(player)
		playerManger.add_child(player)
		player.global_transform = target.global_transform.translated(relativeInfo["nextPosition"])

func physics_process(data_json):
	var type = data_json["type"]
	if stateManager.isNodeType(type, "OneShot"):
		do_input(data_json)
		return
	# oneshot未结束，人物发起其他动作
	stateManager.transformState(type)

func do_input(data_json):
	var type = data_json["type"]
	# 如果存在targetId，改动人物朝向
	var targetId = data_json["targetId"]
	if targetId:
		var targetPlayer = playerManger.player(targetId)
		if targetPlayer:
			player.transform = player.transform.looking_at(targetPlayer.global_transform.origin, Vector3.UP)
		var relativeInfo = model.getRelative(type)
		if relativeInfo:
			var target = playerManger.get_parent().get_node(targetId)
			playerManger.remove_child(player)
			target.add_child(player)
			player.transform.origin = relativeInfo["curPosition"]
			player.look_at(target.global_transform.xform(relativeInfo["curForward"]), Vector3.UP)
	# type不变，重置动画
	if isPlay and _data_json and _data_json["type"] == type:
		model.enableOneShotAnimation()
		trigger_effect(type)
		return
	# oneshot未结束，重新发起不同type的oneshot
	if isPlay and _data_json and _data_json["type"] != type:
		stateEnd()
		eSignalEnd()
	isPlay = true
	model.setAnimation(type)
	model.enableOneShotAnimation()
	music._switchMusic(type)
	del = 0
	_data_json = data_json
	eSignalStart()
	trigger_effect(type)
	
func trigger_effect(type):
	var effectType = model.getSelfEffectType(type)
	if effectType:
		var msgjson = _data_json.duplicate(true)
		msgjson["type"] = effectType
		player._addMoveMessage(msgjson)
