extends Spatial

class_name AnimationPlayerController

var animationPlayer:AnimationPlayer
var timerNode:Timer
var animationName:String

enum PlayMode{ByTimer,ByInstruction}
enum InstructionType{Loop,OneShot,Stop,None}


onready var playMode=PlayMode.ByInstruction
onready var instructionType=InstructionType.None
onready var intervalTime=1.0;

func _init():
	set_process(true)

func SetAnimationPlayer(AnimationPlayerNode:AnimationPlayer):
	animationPlayer=AnimationPlayerNode

func SetPlay(_playMode,_animationPlayer:AnimationPlayer,_animationName,_instructionType,_intervalTime:float):
	# how to check enum type? https://godotengine.org/qa/55016/instanceof-enum-type
	playMode=_playMode
	instructionType=_instructionType
	intervalTime=_intervalTime
	animationName=_animationName
	animationPlayer=_animationPlayer

	match playMode:
		PlayMode.ByInstruction:
			InstructionProcess()
			removeTimer()
		PlayMode.ByTimer:
			print("ByTimer")
			timerNode=Timer.new()
			timerNode.wait_time=intervalTime
			self.add_child(timerNode)
			animationPlayer.connect("animation_finished",self,"StartTimer")
			timerNode.connect("timeout", self, "AnimationPlayOneShot")
			timerNode.start()

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
	print("timerNode start")
	timerNode.start()
	
func AnimationPlayOneShot():
	print("AnimationPlayOneShot")
	AnimationPlay(false)
	
func AnimationPlay(isLoop):
	for animation in animationPlayer.get_animation_list():
		if(animationName and animation==animationName):
			animationPlayer.get_animation(animationName).set_loop(isLoop)
			animationPlayer.play(animationName)
			if(timerNode !=null):
				print("timerNode stop")
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
