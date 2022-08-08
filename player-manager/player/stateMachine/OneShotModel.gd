extends Node

var player
var animationTree
var animation

func _ready() -> void:
	yield(owner, "ready")
	player = owner
	animationTree = player.get_node("AnimationTree")
	animation = GlobalPlayer.actionAnimationInfo.duplicate(true)
	
func enableOneShotAnimation():
	animationTree["parameters/OneShot/blend_amount"] = 1
	animationTree.set("parameters/OneShotStateMachine/Ani/Seek/seek_position", 0)
	
func setAnimation(type):
	var anim = animation[type]["animation"]
	# 使能非混合动画
	var animationNode: AnimationNodeAnimation = animationTree.tree_root\
		.get_node("OneShotStateMachine").get_node("Ani").get_node("Animation")
	animationNode.animation = anim
	if "move_animation" in animation[type]:
		var moveAnimationNode: AnimationNodeAnimation = animationTree.tree_root\
		.get_node("OneShotStateMachine").get_node("Ani").get_node("MoveAnimation")
		moveAnimationNode.animation = animation[type]["move_animation"]
		animationTree["parameters/OneShotStateMachine/Ani/Add2/add_amount"] = 1
	
func isOneShotPlaying():
	return not isAnimationFinished()
	
func isAnimationFinished():
	var playback: AnimationNodeStateMachinePlayback = animationTree.get("parameters/OneShotStateMachine/playback")
	var animPlayer:AnimationPlayer = animationTree.get_node(animationTree.anim_player)
	var anim = animationTree.tree_root.get_node("OneShotStateMachine").get_node("Ani").get_node("Animation").animation
	anim = animPlayer.get_animation(anim)
	if not anim.loop and playback.is_playing():
		var x = playback.get_current_play_position() 
		var y = playback.get_current_length()
		if x and y and y == x:
			return true
	return false
	
func disableOneShotAnimation():
	# 关闭非混合动画
	animationTree["parameters/OneShot/blend_amount"] = 0
	animationTree.set("parameters/OneShotStateMachine/Ani/Seek/seek_position", 0)
	animationTree["parameters/OneShotStateMachine/Ani/Add2/add_amount"] = 0

func inProcessType(type):
	return type in animation and not "mode" in animation[type]

func getRelative(type):
	if "relative" in animation[type]:
		return animation[type]["relative"]
	return null

func getSelfEffectType(type):
	if type in animation and "effect" in animation[type]:
		return animation[type]["effect"]["self"]["type"]
	return null
