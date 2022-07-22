extends Node

var objects=[]

var CameraControlScript=load("res://sceneList/demo21_camera/Scripts/ProtagonistCamera.gd")


var projectionOption

var lookAtTargetTypeOption
var lookAtSpatialOption
var lookAtPointX
var lookAtPointY
var lookAtPointZ

var lerpOption
var lerpSwitch
var lerpSpeed

var distanceMax
var distanceMin
var distanceOffset

var zenithAngelOffset
var azimuthAngelOffset

var zenithAngelOffsetIncrement
var azimuthAngelOffsetIncrement

var cameraNode

onready var HBoxLookAtSpatial = find_node("HBoxLookAtSpatial")
onready var HBoxLookAtPoint = find_node("HBoxLookAtPoint")
onready var HBoxFollow = find_node("HBoxFollow")
onready var HBoxDistance = find_node("HBoxDistance")
onready var HBoxDistanceScroll = find_node("HBoxDistanceScroll")
onready var HBoxZenithAngel = find_node("HBoxZenithAngel")
onready var HBoxAzimuthAngel = find_node("HBoxAzimuthAngel")
onready var HBoxAutoRotate = find_node("HBoxAutoRotate")
onready var HBoxCameraLerpMethod = find_node("HBoxCameraLerpMethod")


func _ready():
	#Setp 1: 找到Camera节点
	cameraNode = find_node("Camera")
	#Setp 2: 给Camera节点绑定脚本
#	cameraNode.set_script(CameraControlScript)
#	cameraNode.set_physics_process(true)

	#Setp 3: 初始化UI界面中的按钮
	InitButton()

func InitButton():
	#Setp 1:查找场景内所有KinematicBody
	for child in get_children():
		if child is KinematicBody:
			objects.append(child)
			
	#Setp 2:绑定UI
	lookAtSpatialOption = find_node("HBoxLookAtSpatial").get_node("OptionButton")
	lookAtTargetTypeOption = find_node("HBoxLookAtTargetType").get_node("OptionButton")
	lookAtPointX =  find_node("HBoxLookAtPoint").get_node("x/TextEdit")
	lookAtPointY =  find_node("HBoxLookAtPoint").get_node("y/TextEdit")
	lookAtPointZ =  find_node("HBoxLookAtPoint").get_node("z/TextEdit")

	lerpOption = find_node("HBoxCameraLerpMethod").get_node("OptionButton")

	lerpSpeed = find_node("HBoxChangeLerp").get_node("Speed/TextEdit")
	lerpSwitch =  find_node("HBoxChangeLerp").get_node("Swicth/Switch/CheckButton")

	distanceMax = find_node("HBoxDistance").get_node("Max/TextEditMax")
	distanceMin = find_node("HBoxDistance").get_node("Min/TextEditMin")
	distanceOffset = find_node("HBoxDistanceScroll").get_node("CenterContainer2/HScrollBar")
	
	zenithAngelOffset = find_node("HBoxZenithAngel").get_node("CenterContainer2/HScrollBar")
	azimuthAngelOffset = find_node("HBoxAzimuthAngel").get_node("CenterContainer2/HScrollBar")
	
	zenithAngelOffsetIncrement = find_node("HBoxZenithAngelIncrement").get_node("CenterContainer2/HScrollBar")
	azimuthAngelOffsetIncrement = find_node("HBoxAzimuthAngelIncrement").get_node("CenterContainer2/HScrollBar")

	#Setp 3:绑定更新事件
	lookAtSpatialOption.connect("item_selected",self,"UpdateLookAtSpatial")
	lookAtTargetTypeOption.connect("item_selected",self,"UpdateLookAtTargetType")
	lookAtPointX.connect("text_changed",self,"UpdateLookAtPoint")
	lookAtPointY.connect("text_changed",self,"UpdateLookAtPoint")
	lookAtPointZ.connect("text_changed",self,"UpdateLookAtPoint")

	lerpSpeed.connect("text_changed",self,"UpdateLerpSpeed")
	lerpSwitch.connect("pressed",self,"UpdateLerpSwitch")

	zenithAngelOffset.connect("value_changed",self,"UpdateZenithAngelOffset")
	azimuthAngelOffset.connect("value_changed",self,"UpdateAzimuthAngelOffse")
	
	zenithAngelOffsetIncrement.connect("value_changed",self,"UpdateZenithAngelOffsetIncrement")
	azimuthAngelOffsetIncrement.connect("value_changed",self,"UpdateAzimuthAngelOffsetIncrement")

	distanceOffset.connect("value_changed",self,"UpdateDistanceOffset")
	
	distanceMin.connect("text_changed",self,"UpdateDistanceMin")
	distanceMax.connect("text_changed",self,"UpdateDistanceMax")

	#Setp 4:选项框初始化选项
	for object in objects:
		lookAtSpatialOption.add_item("item : "+object.name)

	for item in CameraControlScript.LerpMethod:
		lerpOption.add_item(item)

	for item in CameraControlScript.LookAtTargetType:
		lookAtTargetTypeOption.add_item(item)
	
	UpdateProtagonist(null)
	
func UpdateProtagonist(input):
	UpdateLookAtTargetType(null)
	UpdateLookAtSpatial(null)
	UpdateZenithAngelOffset(null)
	UpdateAzimuthAngelOffse(null)
	UpdateDistanceOffset(null)
	UpdateDistanceMin()
	UpdateDistanceMax()
	UpdateLerpSpeed()

func UpdateLookAtSpatial(input):
	cameraNode.lookAtSpatial=objects[lookAtSpatialOption.get_selected_id()].get_path()

func UpdateLookAtPoint():
	cameraNode.lookAtPoint=Vector3(float(lookAtPointX.text),float(lookAtPointY.text),float(lookAtPointZ.text))

func UpdateZenithAngelOffset(input):
	cameraNode.zenithAngelOffset = zenithAngelOffset.value

func UpdateAzimuthAngelOffse(input):
	cameraNode.azimuthAngelOffset = azimuthAngelOffset.value

func UpdateDistanceOffset(input):
	cameraNode.distanceOffset = distanceOffset.value

func UpdateDistanceMin():
	cameraNode.distanceMin=float(distanceMin.text)

func UpdateDistanceMax():
	cameraNode.distanceMax=float(distanceMax.text)

func UpdateLerpSwitch():
	var toggleState = lerpSwitch.is_pressed()
	if(toggleState):
		HBoxCameraLerpMethod.show()
	else:
		HBoxCameraLerpMethod.hide()
	cameraNode.isLerp=toggleState

func UpdateLerpSpeed():
	cameraNode.lerpSpeed=float(lerpSpeed.text)

func UpdateLookAtTargetType(input):
	match lookAtTargetTypeOption.get_selected_id():
		CameraControlScript.LookAtTargetType.SpatialNode:
			HBoxLookAtPoint.hide()
			HBoxLookAtSpatial.show()
			cameraNode.lookAtTargetType=(CameraControlScript.LookAtTargetType.SpatialNode)
			UpdateLookAtSpatial(null)
			
		CameraControlScript.LookAtTargetType.Vector3Point:
			HBoxLookAtPoint.show()
			HBoxLookAtSpatial.hide()
			cameraNode.lookAtTargetType=(CameraControlScript.LookAtTargetType.Vector3Point)
			UpdateLookAtPoint()


func UpdateZenithAngelOffsetIncrement(input):
	cameraNode.SetZenithAngelOffsetIncrement(zenithAngelOffsetIncrement.value)

func UpdateAzimuthAngelOffsetIncrement(input):
	cameraNode.SetAzimuthAngelOffsetIncrement(azimuthAngelOffsetIncrement.value)
