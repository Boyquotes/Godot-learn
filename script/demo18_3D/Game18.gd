extends Node


export (NodePath) var objOptionPath
export (NodePath) var actOptionPath
export (NodePath) var excuteButtonPath
export (NodePath) var groundButtonPath

export (Array) var objectsArray

onready var objOption = get_node(objOptionPath)
onready var actOption = get_node(actOptionPath)
onready var excButton = get_node(excuteButtonPath)
onready var groundButton = get_node(groundButtonPath)

enum ActionType{BounceJump, Fly, Rotate, Vanlish}

var buttonState=false
var actionInstance
func _ready():
	InitButton()
	
	pass # Replace with function body.


func InitButton():
	var objNums=objectsArray.size()
	for i in objNums:
		var obj=get_node(objectsArray[i])
		objOption.add_item("item "+String(i)+":"+obj.name)
	
	for i in ActionType:
		actOption.add_item(i)
	
	excButton.connect("pressed",self,"ExcuteAction")
	groundButton.connect("pressed",self,"GourndAction")
func ExcuteAction():
	print("excute")
	var actSelectedId= actOption.get_selected_id()
	var objSelectedId= objOption.get_selected_id()

	match actSelectedId:
		ActionType.BounceJump:
			if(not buttonState):
				buttonState=true
				#找到要添加Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#添加Action
				actionInstance=JumpAction.new()
				object.add_child(actionInstance)
				#执行Action
				actionInstance.emit_signal("input_activate",null)
				excButton.text="Stop"
			else:
				buttonState=false
				#找到要移除Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#移除Action
				object.remove_child(actionInstance)
				excButton.text="Start"
		ActionType.Fly:
			if(not buttonState):
				buttonState=true
				#找到要添加Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#添加Action
				actionInstance=FlyAction.new()
				object.add_child(actionInstance)
				#执行Action
				actionInstance.emit_signal("input_activate",null)
				excButton.text="Stop"
			else:
				buttonState=false
				#找到要移除Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#移除Action
				object.remove_child(actionInstance)
				excButton.text="Start"
		ActionType.Rotate:
			if(not buttonState):
				buttonState=true
				#找到要添加Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#添加Action
				actionInstance=RotateAction.new()
				object.add_child(actionInstance)
				#执行Action
				actionInstance.emit_signal("input_activate",null)
				excButton.text="Stop"
			else:
				buttonState=false
				#找到要移除Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#移除Action
				object.remove_child(actionInstance)
				excButton.text="Start"
		ActionType.VanlishAction:
			if(not buttonState):
				buttonState=true
				#找到要添加Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#添加Action
				actionInstance=VanlishAction.new()
				object.add_child(actionInstance)
				#执行Action
				actionInstance.emit_signal("input_activate",null)
				excButton.text="Stop"
			else:
				buttonState=false
				#找到要移除Action的节点
				var object=get_node(objectsArray[objSelectedId])
				#移除Action
				object.remove_child(actionInstance)
				excButton.text="Start"
	pass
func GourndAction():
	actionInstance.FlyToGround()
	pass
