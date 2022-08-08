extends Node

var player
var animationTree: AnimationTree
var animation
var addNode

const top_filters = [
	"Armature/Skeleton:f_index.L",
	"Armature/Skeleton:f_index.R",
	"Armature/Skeleton:f_index1.L",
	"Armature/Skeleton:f_index1.R",
	"Armature/Skeleton:f_middle.L",
	"Armature/Skeleton:f_middle.R",
	"Armature/Skeleton:f_middle1.L",
	"Armature/Skeleton:f_middle1.R",
	"Armature/Skeleton:forearm.L",
	"Armature/Skeleton:forearm.R",
	"Armature/Skeleton:hand.L",
	"Armature/Skeleton:hand.R",
	"Armature/Skeleton:head",
	"Armature/Skeleton:neck",
	"Armature/Skeleton:shoulder.L",
	"Armature/Skeleton:shoulder.R",
	"Armature/Skeleton:spine.001",
	"Armature/Skeleton:spine.002",
	"Armature/Skeleton:thumb.L",
	"Armature/Skeleton:thumb.R",
	"Armature/Skeleton:thumb1.L",
	"Armature/Skeleton:thumb1.R",
	"Armature/Skeleton:upper_arm.L",
	"Armature/Skeleton:upper_arm.R"
]

const bottom_filters = [
	"Armature/Skeleton:foot.L",
	"Armature/Skeleton:foot.R",
	"Armature/Skeleton:shin.L",
	"Armature/Skeleton:shin.R",
	"Armature/Skeleton:thigh.L",
	"Armature/Skeleton:thigh.R",
	"Armature/Skeleton:toe.L",
	"Armature/Skeleton:toe.R"
]

func _ready() -> void:
	yield(owner, "ready")
	player = owner
	animationTree = player.get_node("AnimationTree")
	animation = GlobalPlayer.actionAnimationInfo.duplicate(true)
	addNode = animationTree.tree_root.get_node("MixAdd")
	
func setFilterMode(type):
	var mode = animation[type]["mode"]
	match mode:
		GlobalPlayer.mixAnimationMode.NO_FILTER:
			disableAnimationAllFilters()
		GlobalPlayer.mixAnimationMode.TOP_FILTER:
			disableAnimationBottomFilters()
			enableAnimationTopFilters()
		GlobalPlayer.mixAnimationMode.BOTTOM_FILTER:
			disableAnimationTopFilters()
			enableAnimationBottomFilters()

func setAnimation(type):
	var anim = animation[type]["animation"]
	# 使能混合动画
	var animationNode: AnimationNodeAnimation = animationTree.tree_root\
		.get_node("MixStateMachine").get_node("Ani").get_node("Animation")
	animationNode.animation = anim
	setFilterMode(type)
	
func enableAnimation(type, ratio=1):
	animationTree["parameters/MixAdd/blend_amount"] = ratio
	resetPlayer()
	
func disableAnimation(type):
	# 关闭混合动画
	animationTree["parameters/MixAdd/blend_amount"] = 0
	resetPlayer()
	
func enableAnimationFilters(filters):
	for filter in filters:
		addNode.set_filter_path(NodePath(filter), true)
		
func disableAnimationFilters(filters):
	for filter in filters:
		addNode.set_filter_path(NodePath(filter), false)
	
func enableAnimationTopFilters():
	addNode.filter_enabled = true
	enableAnimationFilters(top_filters)
		
func enableAnimationBottomFilters():
	addNode.filter_enabled = true
	enableAnimationFilters(bottom_filters)
	
func disableAnimationTopFilters():
	disableAnimationFilters(top_filters)
	
func disableAnimationBottomFilters():
	disableAnimationFilters(bottom_filters)
	
func disableAnimationAllFilters():
	if not addNode.filter_enabled == false:
		return
	addNode.filter_enabled = false
	disableAnimationTopFilters()
	disableAnimationBottomFilters()
	
func resetPlayer():
	animationTree.set("parameters/MixStateMachine/Ani/Seek/seek_position", 0)
	
func isAnimationFinished():
	var playback: AnimationNodeStateMachinePlayback = animationTree.get("parameters/MixStateMachine/playback")
	var animPlayer:AnimationPlayer = animationTree.get_node(animationTree.anim_player)
	var anim = animationTree.tree_root.get_node("MixStateMachine").get_node("Ani").get_node("Animation").animation
	anim = animPlayer.get_animation(anim)
	if not anim.loop and playback.is_playing():
		var x = playback.get_current_play_position() 
		var y = playback.get_current_length()
		if x and y and y == x:
			return true
	return false

func inProcessType(type):
	return type in animation and "mode" in animation[type]

func getSelfEffectType(type):
	if type in animation and "effect" in animation[type]:
		return animation[type]["effect"]["self"]["type"]
	return null
