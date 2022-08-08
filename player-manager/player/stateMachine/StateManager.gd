extends Node
class_name StateManager

onready var _state: PlayerState
onready var _currentType = GlobalPlayer.State.IDLE
onready var _player : Player
onready var _model
onready var _animationModel
onready var _playerManger
onready var mixStateManager
onready var effectManage

var stateMap = {}

var stateAnimation = {
	GlobalPlayer.State.IDLE: "001_Idle",
	GlobalPlayer.State.WALK: "002_Walk",
	GlobalPlayer.State.JUMP: "021_Jump_Start",
	GlobalPlayer.State.UPJUMP: "132_Jump",
#	GlobalPlayer.State.FLAT_01: "126_flat_01",
#	GlobalPlayer.State.FLAT_02: "127_flat_02",
#	GlobalPlayer.State.FLAT_03: "128_flat_03",
##	GlobalPlayer.State.CREEP: "119_Creep"
#	GlobalPlayer.State.CREEP: "020_Walk",
	GlobalPlayer.State.SIT: "005_Sit_Continue",
	GlobalPlayer.State.FLY: "009_Fly"
}

#var isFirstNull = true
func _ready():
	yield(owner, "ready")
	_player = get_parent()
	_model = _player.get_node("Model")
	_animationModel = get_node("AnimationModel")
	_state = get_node("Stand/Idle")
	_state.enter({})
	_playerManger = _player.get_parent()
	mixStateManager = _player.get_node("MixStateManager")
	effectManage = _player.get_node("EffectManager")
	
func isEnableAnimation():
	var x = _model.get("enableAnimation")
	return x

func _process(delta):
	if isEnableAnimation():
		mixStateManager.process(delta)
		effectManage.process(delta)
	_state.process(delta)
	
var data_json
func _physics_process(delta):
	data_json =  _player._getMoveMessage()
	if _player.get_node("Info")._isSelfPlayer:
		if not _player.get_node("Info")._isAbleMove:
			return 
		if data_json == null:
			_player._curForward = Vector3.ZERO
		else:
			_player._curForward = data_json['curForward']
			data_json['delta'] = delta
	if data_json == null:
		return	
	var type = data_json["type"]
	if type == GlobalPlayer.Action.DISABLE:
		# Action.DISABLE仅用于用户进房间时同步状态，不需要处理
		return
	if isEnableAnimation():
		if mixStateManager.physics_process(data_json):
			return
		if effectManage.physics_process(data_json):
			return
#	SkyBridge.printLog("process type %d" % data_json["type"])
	_state.physics_process(data_json)	

func setAnimation(type, animation):
	if type in stateAnimation:
		stateAnimation[type] = animation
		var target_state = getNodeByType(type)
		var nodePath: NodePath = target_state.get_path()
		var name_count = nodePath.get_name_count()
		if name_count < 1:
			print("get animation name failed!!")
			return
		var subState = nodePath.get_name(name_count - 1)
		var state = nodePath.get_name(name_count - 2)
		_animationModel.setAnimation(state, subState, stateAnimation[type])
		return
	printerr("type %s not found !! can't set animation" % type)

func eSignal(old_type, new_type):
	var type = old_type
	var userId = _player.get_node("Info")._userId
#	print("state end: {0} {1} {2}".format([userId, type, new_type]))
	SignalBus.emit_signal("player_state_change", userId, {
		"lastType": type, 
		"nextType": new_type
	})
	
func transformState(type):
#	SkyBridge.printLog("transform state: type %d" % type)
	if isMove(type) or isStop(type):
		printerr("error!! transform move or stop")
		return
	var target_state = getNodeByType(type)
	if not target_state:
		printerr("transform state %d not found !!" % type)
		return
	if _state == target_state and type == _currentType:
		return
	_state.exit(data_json)
	transitAnimation(type)
	_state = target_state
	_state.enter(data_json)
	if type != _currentType and not isNodeType(type, "OneShot"):
		eSignal(_currentType, type)
	if not isNodeType(type, "OneShot"):
		_currentType = type
		
func transitAnimation(type):
	if not type in stateAnimation:
		return
	var target_state = getNodeByType(type)
	if isNodeType(type, "OneShot"):
		return
	var nodePath: NodePath = target_state.get_path()
	var name_count = nodePath.get_name_count()
	var subState = nodePath.get_name(name_count - 1)
	var state = nodePath.get_name(name_count - 2)
	_animationModel.setAnimation(state, subState, stateAnimation[type])
	if target_state.get_substate():
		subState = target_state.get_substate()
	_animationModel.transition_to(state, subState)
			
func registerState(type, node):
	stateMap[type] = node
	
func getNodeByType(type) -> Node:
	return stateMap.get(type)

func isNodeType(type, nodePath):
	var node:Node = getNodeByType(type)
	return node and node == get_node(nodePath)
	
func inNodeTypes(type, nodePaths):
	for nodePath in nodePaths:
		if isNodeType(type, nodePath):
			return true
	return false
	
#func oneShotReturn():
#	transformState(_currentType)

func getCurrentState():
	return _currentType

func isMove(type):
	return type == GlobalPlayer.State.MOVE
	
func isStop(type):
	return type == GlobalPlayer.State.STOP
	
func get_stop_state():
	return _state.get_stop_type()
	
func get_move_state():
	return _state.get_move_type()
