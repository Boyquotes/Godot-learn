extends Node

onready var player : Player
onready var info : Info
onready var stateManager
onready var playerManger
onready var model


func _ready() -> void:
	yield(owner, "ready")
	player = owner
	info = player.get_node("Info")
	playerManger = player.get_parent()
	model = get_node("AnimationModel")
	
var _data_json = {}

func animationProcess(type):
	if model.inProcessType(type):
		model.enableAnimation(type)
		return true
	return false
	
func process(delta):
	pass
		
func addAnimationCallback(animationPlayer):
	var data_json = _data_json.duplicate(true)
	animationPlayer.connect("animation_finished", self, "_on_animation_finished", [animationPlayer, data_json])
	
func _on_animation_finished(anim, animationPlayer, data_json):
	stateEnd(data_json)
	animationPlayer.disconnect("animation_finished", self, "_on_animation_finished")
	
func addTimerCallback(timer):
	var data_json = _data_json.duplicate(true)
	timer.connect("timeout", self, "stateEnd", [data_json])
	self.add_child(timer)
	
func stateEnd(data_json):
	var type = data_json["type"]
	model.disableAnimation(type)
	var targetId = data_json["targetId"]
	if not targetId:
		return
	var targetType = model.getTargetEffectType(type)
	if not targetType:
		return
	var targetPlayer = playerManger.player(targetId)
	if not targetPlayer:
		return
	var msgjson = GlobalPlayer.EMPTY_MOVE_MSG_JSON.duplicate(true)
	msgjson["type"] = targetType
	targetPlayer._addMoveMessage(msgjson)

func physics_process(data_json):
	var type = data_json["type"]
	_data_json = data_json
	if animationProcess(type):
		return true
	_data_json = {}
	return false
