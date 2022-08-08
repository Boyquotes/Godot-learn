extends Node

var player
var animationTree
var animation

func _ready() -> void:
	yield(owner, "ready")
	player = owner
	animationTree = player.get_node("AnimationTree")
	animation = GlobalPlayer.effectAnimationInfo.duplicate(true)
	
func enableAnimation(type, ratio=1):
	var animationPlayer
	if not "instance" in animation[type] or not animation[type]["instance"]:
		var model = player.get_node("Model")
		if "bone" in animation[type]:
			# 绑骨
			animation[type]["instance"] = model.enablePropFromFile(animation[type]["bone"], animation[type]["scene"])
		else:
			# 不绑骨
			animation[type]["instance"] = ResourceLoader.load(animation[type]["scene"]).instance()
			player.get_node("Model/Armature/Skeleton").add_child(animation[type]["instance"])
	if "animation" in animation[type]:
		animationPlayer = animation[type]["instance"].get_node("AnimationPlayer")
		get_parent().addAnimationCallback(animationPlayer)
		animationPlayer.seek(0, true)
		animationPlayer.play(animation[type]["animation"])
	else:
		if not "last_time" in animation[type]:
			animation[type]["last_time"] = 1
		var timer = Timer.new()
		timer.one_shot = true
		timer.autostart = true
		timer.wait_time = animation[type]["last_time"]
		get_parent().addTimerCallback(timer)

func disableAnimation(type):
	if "animation" in animation[type]:
		return
	if not "instance" in animation[type] or not animation[type]["instance"]:
		return
	var model = player.get_node("Model")
	model.disablePropFromFile(animation[type]["bone"], animation[type]["scene"])
	animation[type]["instance"] = null
	
func inProcessType(type):
	return type in animation

func getTargetEffectType(type):
	if type in animation and "effect" in animation[type]:
		return animation[type]["effect"]["target"]["type"]
	return null
