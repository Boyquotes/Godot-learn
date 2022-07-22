extends Control

enum GroupType{Fast, Middle, Slow}
onready var button0 = get_node("VBoxContainer/HBoxContainer/L1")
onready var button1 = get_node("VBoxContainer/HBoxContainer/L2")
onready var button2 = get_node("VBoxContainer/HBoxContainer/L3")
onready var button3 = get_node("VBoxContainer/HBoxContainer/L4")


onready var lightBlock0 = get_node("HBoxContainer/c1")
onready var lightBlock1 = get_node("HBoxContainer/c2")
onready var lightBlock2 = get_node("HBoxContainer/c3")
onready var lightBlock3 = get_node("HBoxContainer/c4")
onready var lightBlocks = []

onready var LaunchPadController = get_node("GameLogic/LaunchPadController")

onready var label1 = get_node("Label/speed")
onready var label2 = get_node("Label2/level")

onready var currentLevel = -1
onready var currentType = GroupType.Fast

func _ready():
	button0.connect("button_up",self,"UpLevel")
	button1.connect("button_up",self,"DownLevel")
	button2.connect("button_up",self,"ChangeType")
	button3.connect("button_up",self,"ChangeCombination")
	LaunchPadController.connect("beat",self,"Onbeat")
	

	lightBlocks.append(lightBlock0)
	lightBlocks.append(lightBlock1)
	lightBlocks.append(lightBlock2)
	lightBlocks.append(lightBlock3)
	
	

func UpLevel():
	currentLevel+=1
	if(currentLevel==6):
		currentLevel=5
		return
	label2.text = str(currentLevel)
	$GameLogic/LaunchPadController.LaunchAudio(currentType, currentLevel)
	pass

func DownLevel():
	currentLevel-=1
	if(currentLevel==-2):
		currentLevel = -1
		return
	label2.text = str(currentLevel)
	$GameLogic/LaunchPadController.LaunchAudio(currentType, currentLevel)
	pass

func ChangeCombination():
	$GameLogic/LaunchPadController.LaunchAudio(currentType, currentLevel)
	pass
	
func ChangeType():
	currentType = currentType + 1
	if (currentType == 3):
		currentType = 0
	label1.text = str(currentType)
	ChangeCombination()

var currentBeatBlock = -1
func Onbeat():
	currentBeatBlock = (currentBeatBlock+1) %4
	changeLightBlock(currentBeatBlock)

	
func changeLightBlock(index):
	for i in range(4):
		lightBlocks[i].material.set_shader_param("color",Color(1,1,1,1));
		
	lightBlocks[index].material.set_shader_param("color",Color(1,0,0,1));
