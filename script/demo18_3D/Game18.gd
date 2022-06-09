extends Node


export (NodePath) var objOptionPath
export (NodePath) var actOptionPath
export (NodePath) var excuteButtonPath

export (Array) var objectsArray

onready var objOption = get_node(objOptionPath)
onready var actOption = get_node(actOptionPath)
onready var excButton = get_node(excuteButtonPath)

enum ActionType{Jump, Fly, Rotate}

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

	actOption.add_item("Jump")
	actOption.add_item("Fly")
	actOption.add_item("Rotate")
	
	excButton.connect("pressed",self,"ExcuteAction")
	
func ExcuteAction():
	print("excute")
	var actSelectedId= actOption.get_selected_id()
	var objSelectedId= objOption.get_selected_id()
	
	match actSelectedId:
		0:
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
				
		1:
			print(1)
		_:
			print(2)
		
	pass
