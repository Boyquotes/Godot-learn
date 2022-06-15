extends Spatial
#用于控制AnimationPlayer的脚本，使用时挂载到AnimationPlayer的父节点
#接口1 SetPlay：动画名字，指令(Loop,OneShot,Stop,ByTimer)，间隔（仅当指令为ByTimer有用）
#接口2 getAnimation：返回所控制的AnimationPlayer所有动画名字

class_name AnimationPlayerController

var animationPlayer:AnimationPlayer
var timerNode:Timer
var animationName:String

enum InstructionType{Loop,OneShot,Stop,ByTimer,None}

onready var instructionType=InstructionType.None
onready var intervalTime=1.0;


func SetPlay(_animationName,_instructionType,_intervalTime:float):
	# how to check enum type? https://godotengine.org/qa/55016/instanceof-enum-type
	instructionType=_instructionType
	intervalTime=_intervalTime
	animationName=_animationName

	match instructionType:
		InstructionType.ByTimer:
			
			timerNode=Timer.new()
			timerNode.wait_time=intervalTime
			self.add_child(timerNode)
			animationPlayer.connect("animation_finished",self,"StartTimer")
			timerNode.connect("timeout", self, "AnimationPlayOneShot")
			timerNode.start()
		_:
			InstructionProcess()
			removeTimer()

func getAnimation():
	return animationPlayer.get_animation_list()

func _init():
	set_process(true)
	FindAnimationPlayerNodeInTree(self)
	print(getAnimation())

func FindAnimationPlayerNodeInTree(root:Node):
	if animationPlayer !=null:
		return
	if root is AnimationPlayer:
		animationPlayer=root
		return
	for childNode in root.get_children():
		FindAnimationPlayerNodeInTree(childNode)

func InstructionProcess():
	match instructionType:
		InstructionType.None:
			pass
		InstructionType.OneShot:
			AnimationPlayOneShot()
			instructionType=InstructionType.None
		InstructionType.Loop:
			AnimationPlay(true)
			instructionType=InstructionType.None
		InstructionType.Stop:
			AnimationStop()
			instructionType=InstructionType.None

func StartTimer(animationName):
	if instructionType==InstructionType.ByTimer:
		timerNode.start()

func AnimationPlayOneShot():
	
	AnimationPlay(false)

func AnimationPlay(isLoop):
	for animation in animationPlayer.get_animation_list():
		if(animationName and animation==animationName):
			animationPlayer.get_animation(animationName).set_loop(isLoop)
			animationPlayer.play(animationName)
			if instructionType==InstructionType.ByTimer:
				timerNode.stop()
			return
	print("There is no animation named "+animationName)

func AnimationStop():
	for animation in animationPlayer.get_animation_list():
		if(animationName and animation==animationName):
			animationPlayer.stop(true)
			return
	print("There is no animation named "+animationName)

func removeTimer():
	for node in get_children():
		if(node.get_class()=="Timer"): 
			node.queue_free()


