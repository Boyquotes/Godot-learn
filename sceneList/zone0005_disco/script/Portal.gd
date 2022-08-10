extends Spatial
signal done

onready var lerpSpeed = 0.2
onready var targetScenePath = "res://sceneList/zone0005_disco/Disco.tscn"

onready var loadTriggerNode = $"LoadTrigger"
onready var enterTrigger = $"EnterTrigger"
onready var teleportTrigger = $"TeleportTrigger"


onready var portalTargetSceneNode = get_tree ().get_root ().find_node("PortalTargetScene", true, false)
onready var passageway = $"passageway"
onready var tweenNode = $"Tween"
onready var animationPlayer = $"AnimationPlayer"
#thread load
onready var resourceAsyncLoader = ResourceAsyncLoader.new()
#onready var thread: = Thread.new()
onready var mutex = Mutex.new()
onready var threadTask = null
onready var threadTaskOut = null

onready var targetViewport = get_tree ().get_root ().find_node("TargetViewport", true, false)
onready var targetCamera = targetViewport.get_node("Spatial/Camera")

onready var inEnterArea = false
onready var portalReady = false


func _ready():
	loadTriggerNode.connect("body_entered",self, "OnLoadTriggerBodyEnteredCallback")
	enterTrigger.connect("body_entered", self, "OnEnterTriggerBodyEnteredCallback")
	enterTrigger.connect("body_exited", self, "OnEnterTriggerBodyExitedCallback")
	resourceAsyncLoader.start()
#	thread.start(self, 'threaded_load', 0)


func _physics_process(delta):
	UpdateTargetCamera()



func OnLoadTriggerBodyEnteredCallback(body):
	if(body.name.find("Player")!=-1):
		PortalLoad()

func OnEnterTriggerBodyEnteredCallback(body):
	if(body.name.find("Player")!=-1):
		inEnterArea = true
		if(portalReady):
			EnterPortal()
			
func OnEnterTriggerBodyExitedCallback(body):
	if(body.name.find("Player")!=-1):
		inEnterArea = false


func PortalLoad():
	#Step 1: Load target scene
#	threadTask = targetScenePath
#	yield(self, "done")
	threadTaskOut = load(targetScenePath).instance()
	var childeNumber = threadTaskOut.get_child_count()
	
	for i in range(childeNumber):
		
		var child = threadTaskOut.get_child(0)
		threadTaskOut.remove_child(child)
		portalTargetSceneNode.add_child(child)
		child.set_owner(portalTargetSceneNode)

		yield(get_tree(),"idle_frame")
		
	threadTaskOut.queue_free()
#	portalTargetSceneNode.add_child(threadTaskOut)

	#Step 2: Open passageway
	ShowPassageway()
	portalReady = true
	if(inEnterArea):
		EnterPortal()
		
#region Internal Method 
func ShowPassageway():
	passageway.show()
	animationPlayer.play("PassagewayOpen")


func EnterPortal():
	#Step 1: unenable camera scirpt
	var currentCamera = get_viewport().get_camera()
	currentCamera.set_process(false) 
	currentCamera.set_physics_process(false)
	#Step 2: create camera path
	var curves = CalPath(get_viewport().get_camera().global_translation, passageway.global_translation)

	var pathNode = Path.new()
	var pathFollow = PathFollow.new()
	var tween = Tween.new()
	currentCamera.get_parent().add_child(pathNode)
	print("currentCamera.get_parent().add_child(pathNode)")
	pathNode.add_child(pathFollow)
	print("pathNode.add_child(pathFollow)")
	pathNode.add_child(tween)
	print("pathNode.add_child(tween)")

	currentCamera.get_parent().remove_child(currentCamera)
	pathFollow.add_child(currentCamera)
	currentCamera.translation = Vector3(0, 0, 0)
	print("currentCamera.parent = pathFollow")
	pathNode.curve = curves
	
	tween.interpolate_property(pathFollow, "unit_offset", 0, 1, 6)
	tween.start()
	
	
func UpdateTargetCamera():
	var currentCamera = get_viewport().get_camera()
	var trans = global_transform.inverse() * currentCamera.global_transform
	trans = trans.rotated(Vector3.UP, PI)
	targetCamera.transform = trans
	targetViewport.size = get_viewport().size

	


func CalPath(currentPosition, targetPosition):
	var curves = Curve3D.new()

	var p1 = (currentPosition + targetPosition)/2
	p1.y -= 5
	var interpolationNum = 128
	for i in range(interpolationNum):
		var t=(1.0/(interpolationNum-1)) * i
		curves.add_point(QuadraticBezier(currentPosition, p1, targetPosition, t))
	return curves
	
#endregion


func threaded_load(id):
	while(true):
		if threadTask != null :
			threadTaskOut = load(threadTask).instance()
			threadTask = null
			call_deferred('emit_signal', 'done')



#region ToolScript

func LinearInterpolate(p0: Vector3, p1: Vector3,t: float):
	return (p1-p0) * clamp(t,0,1) + p0

func QuadraticBezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = LinearInterpolate(p0, p1, t)
	var q1 = LinearInterpolate(p1, p2, t)
	return LinearInterpolate(q0,q1,t)

func CubicBezier(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float):
	var q0 = LinearInterpolate(p0, p1, t)
	var q1 = LinearInterpolate(p1, p2, t)
	var q2 = LinearInterpolate(p2, p3, t)

	var r0 = LinearInterpolate(q0, q1, t)
	var r1 = LinearInterpolate(q1, q2, t)

	return LinearInterpolate(r0, r1, t)

#endregion

func LookAt(taregtPosition, worldUp=Vector3.UP):
	look_at(taregtPosition, worldUp)
	# var cameraAxis_Z =(transform.origin-taregtPosition).normalized()

	# var cameraAxis_X= worldUp.cross(cameraAxis_Z).normalized()
	
	# var cameraAxis_Y= cameraAxis_Z.cross(cameraAxis_X)
	
	# transform.basis=Basis(cameraAxis_X,cameraAxis_Y,cameraAxis_Z)

func LookAtLerp(camera, taregtPosition, worldUp=Vector3.UP):
	var cameraAxis_Z =(camera.transform.origin-taregtPosition).normalized()

	var cameraAxis_X= worldUp.cross(cameraAxis_Z).normalized()
	
	var cameraAxis_Y= cameraAxis_Z.cross(cameraAxis_X)

	var quat = Quat(camera.transform.basis).slerp(Quat(Basis(cameraAxis_X,cameraAxis_Y,cameraAxis_Z)),lerpSpeed*4) 

	camera.transform.basis = Basis(quat)


func LookAtPosition(position, taregtPosition, worldUp=Vector3.UP):
	look_at_from_position(position, taregtPosition, worldUp)
	# transform.origin=position
	# LookAt(taregtPosition,worldUp)

func LookAtPositionLerp(moveTaregtposition, lookAtTaregtPosition, worldUp=Vector3.UP):
	transform.origin= lerp(transform.origin, moveTaregtposition, lerpSpeed)  
	LookAt(lookAtTaregtPosition, worldUp)

