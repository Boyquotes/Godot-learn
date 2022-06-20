extends Node

var objects=[]

var CameraControlScript=load("res://sceneList/demo21_camera/Scripts/CameraControl.gd")

var cameraModeOption
var cameraSubModeOption

var lookAtOption
var followOption
var projectionOption

var distanceMax
var distanceMin
var distanceOffset
var angelOffset


var cameraNode


onready var HBoxLookAt=find_node("HBoxLookAt")
onready var HBoxFollow=find_node("HBoxFollow")
onready var HBoxDistance=find_node("HBoxDistance")
onready var HBoxDistanceScroll=find_node("HBoxDistanceScroll")
onready var HBoxAngel=find_node("HBoxAngel")
onready var HBoxAutoRotate=find_node("HBoxAutoRotate")


func _ready():
	#Setp 1: 找到Camera节点
	cameraNode = find_node("Camera")
	#Setp 2: 给Camera节点绑定脚本
	cameraNode.set_script(CameraControlScript)
	
	#Setp 3: 初始化UI界面中的按钮
	InitButton()

func InitButton():
	#Setp 1:查找场景内所有KinematicBody
	for child in get_children():
		if child is KinematicBody:
			objects.append(child)
			
	#Setp 2:绑定UI
	cameraModeOption = find_node("HBoxCameraMode").get_node("OptionButton")
	cameraSubModeOption = find_node("HBoxCameraSubMode").get_node("OptionButton")
	
	lookAtOption = find_node("HBoxLookAt").get_node("OptionButton")
	followOption = find_node("HBoxFollow").get_node("OptionButton")
	projectionOption = find_node("HBoxCameraProjection").get_node("OptionButton")
	
	distanceMax = find_node("HBoxDistance").get_node("TextEditMax")
	distanceMin = find_node("HBoxDistance").get_node("TextEditMin")
	distanceOffset = find_node("HBoxDistanceScroll").get_node("HScrollBar")
	angelOffset = find_node("HBoxAngel").get_node("HScrollBar")

	#Setp 3:绑定更新事件
	cameraModeOption.connect("item_selected",self,"UpdateUILevel0")
	cameraSubModeOption.connect("item_selected",self,"UpdateUILevel1")
	
	lookAtOption.connect("item_selected",self,"SetCameraController")
	followOption.connect("item_selected",self,"SetCameraController")
	projectionOption.connect("item_selected",self,"SetCameraController")
	
	
	for object in objects:
		lookAtOption.add_item("item : "+object.name)
		followOption.add_item("item : "+object.name)
	
	for item in CameraControlScript.ProjectionMode:
		projectionOption.add_item(item)
		
	for item in CameraControlScript.CameraMode:
		cameraModeOption.add_item(item)

	UpdateUILevel0(null)
	
func UpdateUILevel0(input):
	match cameraModeOption.get_selected_id():
		CameraControlScript.CameraMode.Protagonist:
			cameraSubModeOption.clear()
			for item in CameraControlScript.ProtagonistMode:
					cameraSubModeOption.add_item(item)

		CameraControlScript.CameraMode.FreeLook:
			cameraSubModeOption.clear()
			for item in CameraControlScript.FreeLookMode:
					cameraSubModeOption.add_item(item)
					
	UpdateUILevel1(null)

func UpdateUILevel1(input):
	match cameraModeOption.get_selected_id():
		CameraControlScript.CameraMode.Protagonist:
			UpdateUIProtagonist(null)

		CameraControlScript.CameraMode.FreeLook:
			UpdateUIFreeLook(null)
	#每次UI更新，都要更新相机脚本的参数
	SetCameraController(null)
	
func UpdateUIProtagonist(input):
	HBoxLookAt.show()
	HBoxFollow.show()
	HBoxAngel.show()
	HBoxAutoRotate.show()
	match cameraSubModeOption.get_selected_id():
		
		CameraControlScript.ProtagonistMode.Circle:
			HBoxDistance.show()
			HBoxDistanceScroll.show()
			
		CameraControlScript.ProtagonistMode.Sphere:
			HBoxDistance.hide()
			HBoxDistanceScroll.hide()


func UpdateUIFreeLook(input):
	HBoxLookAt.hide()
	HBoxFollow.hide()

	
func SetCameraController(input):
	#Setp 1: 从UI读取参数，准备设置参数
	var configDict = ConfigBuilder()

	#Setp 2: 配置相机脚本
	cameraNode.SetCamera(configDict)

func ConfigBuilder():
	var configDict={}
	#Mode
	configDict.cameraMode=cameraModeOption.get_selected_id()
	configDict.cameraSubMode=cameraSubModeOption.get_selected_id()
	#Common
	configDict.projectionMode=projectionOption.get_selected_id()
	configDict.cameraSubMode=cameraSubModeOption.get_selected_id()
	match cameraModeOption.get_selected_id():
		CameraControlScript.CameraMode.Protagonist:

			configDict.lookAtObj= objects[lookAtOption.get_selected_id()]
			configDict.followObj = objects[followOption.get_selected_id()]
			configDict.projectionMode = projectionOption.get_selected_id()
			pass
		CameraControlScript.CameraMode.FreeLook:
			pass
	return configDict
			
