extends Node

var player
var animationTree #setget setAnimationTree,getAnimationTree

func _ready() -> void:
	yield(owner, "ready")
	player = owner
	animationTree = player.get_node("AnimationTree")

func setAnimation(status, subStatus, animation):
	# 设置人物动画
	var animationNode: AnimationNodeAnimation = animationTree.tree_root\
		.get_node("StateMachine")\
		.get_node(status)\
		.get_node(subStatus)\
		.get_node("Animation")
	animationNode.animation = animation
	
func transition_to(state, subState) -> void:
	var subPlayback: AnimationNodeStateMachinePlayback = animationTree.get("parameters/StateMachine/" + state + "/playback")
	var playback: AnimationNodeStateMachinePlayback = animationTree.get("parameters/StateMachine/playback")
	# 同一个子状态机travel
	if playback.get_current_node() == state:
		subPlayback.travel(subState)
		return
	# 跨子状态机设置start节点，travel父状态机
	var ansm: AnimationNodeStateMachine = animationTree.tree_root\
		.get_node("StateMachine")\
		.get_node(state)
	ansm.set_start_node(subState)
	playback.travel(state)
	if subState == "Flat" and "AvatarC" in player.get_node("Model").modelPath:
		player.get_node("Model").translation = Vector3(0,0.9,0)
	else:
		player.get_node("Model").translation = Vector3(0,0,0)
