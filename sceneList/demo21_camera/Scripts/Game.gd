extends Node

var objects=[]

var CameraControlScript=load("res://sceneList/demo21_camera/Scripts/CameraControl.gd")

var CameraOption
var LookAtOption
var FollowOption
var ProjectionOption

func _ready():
	
	InitButton()

func InitButton():
	#Setp 1:查找场景内所有KinematicBody
	for child in get_children():
		if child is KinematicBody:
			objects.append(child)
			
	CameraOption = find_node("HBoxCamera").get_node("OptionButton")
	LookAtOption = find_node("HBoxLookAt").get_node("OptionButton")
	FollowOption = find_node("HBoxFollow").get_node("OptionButton")
	ProjectionOption = find_node("HBoxCameraProjection").get_node("OptionButton")

	CameraOption.connect("item_selected",self,"UpdateUI")
	LookAtOption.connect("item_selected",self,"UpdateUI")
	FollowOption.connect("item_selected",self,"UpdateUI")
	ProjectionOption.connect("item_selected",self,"UpdateUI")
	
	for object in objects:
		LookAtOption.add_item("item : "+object.name)
		FollowOption.add_item("item : "+object.name)
	
	for item in CameraControlScript.ProjectionMode:
		ProjectionOption.add_item(item)
		
	for item in CameraControlScript.CameraMode:
		CameraOption.add_item(item)

	
func UpdateUI(input):
	print("UI change")
	SetCameraController()
	pass


func SetCameraController():

	var configDict={}
	configDict.cameraMode=CameraOption.get_selected_id()
	configDict.lookAtObj= objects[LookAtOption.get_selected_id()]
	configDict.followObj = objects[FollowOption.get_selected_id()]
	configDict.projectionMode = ProjectionOption.get_selected_id()
	
	var cameraNode = find_node("Camera")
	cameraNode.set_script(CameraControlScript)
	cameraNode.SetCamera(configDict)
	
	pass
