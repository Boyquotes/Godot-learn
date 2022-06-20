extends Node2D

var debugLayoutScrpt = load("res://sceneList/demo20_DebugTool/prefab/DebugLayoutDemo.gd")
var debugLayout


# fake debug variable
var roomID="4216t1251531r1tg14534"
var userToken="rgheriowughio1yht24oh409iugejkb093hjy901243ut9043jtkgeiqjbh3i[ouyhj234i0="

func _ready():
	
	debugLayout= Node.new()
	debugLayout.set_script(debugLayoutScrpt)
	add_child(debugLayout)
	
	#add fake variable to creat debug lable ui
	debugLayout.labelDict["roomID"]=roomID
	debugLayout.labelDict["userToken"]=userToken
	
	
var i =0
func _process(delta):
	
	i+=1
	if(i==120):
		i=0
		debugLayout.DebugPrint("masmdfiashgbiulegbhnwilahvgn fhsdaiufhasdiljgb")
