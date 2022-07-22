extends Control

signal pressed

enum CheckType {SetProgress, SetTriggerValue}

var buttonProgress = 0.0
var triggerValue = 0.8

var showPosition = Vector2(-40,0)
var hidePosition = Vector2(1298,330)



#region Internal Variable
onready var GoGrayMaterial = $CenterContainerTexture/TextureButtonGreen.material;
onready var TextureButtonGreenMaterial= $CenterContainerTexture/CenterContainer/GoGray.material;

onready var hscroll = $HScrollBar;
#endregion

#region Godot Callback

func _ready():
	$HScrollBar.connect("value_changed",self,"SetProgress")

#endregion

#region Public Method

func SetProgress(value):
	if(!Check(value, CheckType.SetProgress)):
		return
	GoGrayMaterial.set_shader_param("buttonProgress",value);
	TextureButtonGreenMaterial.set_shader_param("buttonProgress",value);
#endregion


#region Goddot Callback
func _gui_input(event):
	if event is InputEventScreenTouch:
#		print()
		if event.is_pressed():
			emit_signal("pressed")


#endregion


#region Internal Method


	
func Check(value, checkType):
	match checkType:
		CheckType.SetProgress:
			if(value>1 or value<0):
				print("SetProgress Error! Value mast betwween 0 and 1!")
				return false
	match checkType:
		CheckType.SetTriggerValue:
			if(value>1 or value<0):
				print("SetTriggerValue Error! Value mast betwween 0 and 1!")
				return false
	return true
#endregion


