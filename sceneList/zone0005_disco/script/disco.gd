extends Spatial
enum PlayMode{ByTimer,ByInstruction}
enum InstructionType{Start,Stop}
onready var animationPlayerNode:Array= []

func _ready():
	
	# Step 1: find all AnimationPlayer Node
	FindAnimationPlayerNodeInTree(self,animationPlayerNode)
	# Setp 2 : shwo in UI
	InitButton()

	pass
	
	
func FindAnimationPlayerNodeInTree(root:Node,res:Array):
	
	if root is AnimationPlayer  and CheckAdd(root):
		res.append(root)
	for childNode in root.get_children():
		FindAnimationPlayerNodeInTree(childNode,res)
	pass



#检查 AnimationPlayer Node是否满足某种条件（例如，它的父节点是Spatial节点）  不满足条件的不通过
func CheckAdd(node:Node):
	
	
	if(node.get_parent() is Spatial):
		return true
	else:
		return false
	
	pass


func InitButton():
	# init option mode
	
	var modeOption = find_node("OptionMode")
	for item in PlayMode:
		modeOption.add_item(item)

	
	var objOption = find_node("OptionObj")
	for node in animationPlayerNode:
		objOption.add_item(node.get_path())
		
	var instrOption = find_node("OptionInstr")
	for item in InstructionType:
		instrOption.add_item(item)
	pass
