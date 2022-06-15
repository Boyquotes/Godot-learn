extends Spatial

var modeOption
var objOption
var aniOption
var instrOption



onready var animationPlayerNode:Array= []
onready var controllerScript=preload("res://sceneList/zone0005_disco/script/AnimationPlayerController.gd" )


func _ready():
	
	# Step 1: find all AnimationPlayer Node
	FindAnimationPlayerNodeInTree(self,animationPlayerNode)
	# Setp 2 : shwo in UI
	InitButton()

	
func FindAnimationPlayerNodeInTree(root:Node,res:Array):
	
	if root is AnimationPlayer  and CheckAdd(root):
		res.append(root)
	for childNode in root.get_children():
		FindAnimationPlayerNodeInTree(childNode,res)

#检查 AnimationPlayer Node是否满足某种条件（例如，它的父节点是Spatial节点）  不满足条件的不通过
func CheckAdd(node:Node):
	if(node.get_parent() is Spatial):
		return true
	else:
		return false

func InitButton():

	objOption = find_node("OptionObj")
	objOption.connect("item_selected",self,"UIUpdateAnimation")
	for node in animationPlayerNode:
		objOption.add_item(node.get_path())                    
		
	aniOption= find_node("OptionAni")
	for animation in animationPlayerNode[objOption.get_selected_id()].get_animation_list ( ):
		aniOption.add_item(animation)    
			
	instrOption = find_node("OptionInstr")
	instrOption.connect("item_selected",self,"UIUpdateInstr")
	for item in AnimationPlayerController.InstructionType:
		instrOption.add_item(item)

	var setButton = find_node("ButtonSet")
	setButton.connect("pressed",self,"AddScript")


func AddScript():
	#Step 1:获取要操作的obj的id和对应的父节点
	var objOptionID=objOption.get_selected_id()
	var controllerNode=animationPlayerNode[objOptionID].get_parent()
	
	#Step 2:向要操作的obj的父节点添加控制脚本
	controllerNode.set_script(controllerScript)

	#Step 3:从UI获取参数

	var instrOptionID=instrOption.get_selected_id()
	var IntervalValue = float(find_node("TextEditInterval").get_line(0))
	
	#Step 4:动画名字，指令(Loop,OneShot,Stop,timer)，间隔
	controllerNode.SetPlay(aniOption.get_item_text(aniOption.get_selected_id()),instrOptionID,IntervalValue)
	

func UIUpdateInstr(i):
	var ModeTimerNode = find_node("ModeTimer")

	print("UI update")
	match i:
		AnimationPlayerController.InstructionType.ByTimer:
			ModeTimerNode.show()
		_:
			ModeTimerNode.hide()
			
func UIUpdateAnimation(i):
	aniOption= find_node("OptionAni")
	aniOption.clear()
	for animation in animationPlayerNode[i].get_animation_list ( ):
		aniOption.add_item(animation)   
