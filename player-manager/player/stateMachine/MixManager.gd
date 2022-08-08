extends Node

onready var player : Player
onready var info : Info
onready var stateManager
onready var playerManger
onready var model
onready var music


func _ready() -> void:
	yield(owner, "ready")
	player = owner
	info = player.get_node("Info")
	playerManger = player.get_parent()
	model = get_node("AnimationModel")
	music = get_node("ActionMusic")
	
var _data_json = {}
var isMix = false

func animationProcess(data_json):
	var type = data_json["type"]
	# 非mix处理type
	if not model.inProcessType(type):
		return false
	setUserForward(data_json)
	# 不同type的mix中断
	if isMix and _data_json:
		model.disableAnimation(_data_json["type"])
		eSignalEnd()
	var oneShotManager = player.get_node("StateManager").get_node("OneShot")
	if oneShotManager.isPlay:
		oneShotManager.oneShotReturn()
	# mix处理
	model.setAnimation(type)
	model.enableAnimation(type)
	_data_json = data_json
	music._switchMusic(type)
	eSignalStart()
	isMix = true
	del = 0
	trigger_effect(type)
	
func trigger_effect(type):
	var effectType = model.getSelfEffectType(type)
	if effectType:
		var msgjson = _data_json.duplicate(true)
		msgjson["type"] = effectType
		player._addMoveMessage(msgjson)
	return true
	
func mixReturn():
	if not _data_json:
		return
	model.disableAnimation(_data_json["type"])
	isMix = false
	stateEnd()
	eSignalEnd()
	music.stopMusic()
	_data_json = {}

var del = 0
func process(delta):
	while del < 0.5:
		del += delta
		return
	if isMix and model.isAnimationFinished() and _data_json:
		mixReturn()
		
func stateEnd():
	pass
#	var type = _data_json["type"]
#	var effectType = model.getSelfEffectType(type)
#	if not effectType:
#		return
#	var msgjson = _data_json.duplicate(true)
#	msgjson["type"] = effectType
#	player._addMoveMessage(msgjson)

func eSignalStart():
	var userId = player.get_node("Info")._userId
	var type = _data_json["type"]
	print("mix action start: {0} {1}".format([userId, type]))
	SignalBus.emit_signal("player_action_start", userId, _data_json)
	
func eSignalEnd():
	var userId = player.get_node("Info")._userId
	var type = _data_json["type"]
	print("mix action end: {0} {1}".format([userId, type]))
	SignalBus.emit_signal("player_action_end", userId, _data_json)

func setUserForward(data_json):
	var targetId = data_json["targetId"]
	if targetId:
		var targetPlayer = playerManger.player(targetId)
		if targetPlayer:
			player.transform = player.transform.looking_at(targetPlayer.global_transform.origin, Vector3.UP)

func physics_process(data_json):
	var type = data_json["type"]
	# mix被oneshot中断，后续oneshot处理
	if isMix and player.get_node("StateManager").isNodeType(type, "OneShot"):
		mixReturn()
		return false
	# 相同type的mix中断，重置动画进度
	if isMix and _data_json and _data_json["type"] == type:
		model.enableAnimation(type)
		setUserForward(data_json)
		trigger_effect(type)
		return true
	# mix处理
	return animationProcess(data_json)
