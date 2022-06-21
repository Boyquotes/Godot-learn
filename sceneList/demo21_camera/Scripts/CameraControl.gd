#CameraController V0.1 2022.6.21
#Code By Xmy 
extends Spatial

enum CameraMode {Protagonist,FreeLook}
enum ProtagonistMode{Circle, Sphere}
enum FreeLookMode{OnPlane}

enum ProjectionMode{Perspective , Orthogonal}
enum LerpMethod{Defalut}
enum LookAtTargetType{SpatialNode,Vector3Point}

enum CheckType{SetMode,SetSubMode,SetLookAtTargetType,SetLookAtSpatial,SetLookAtPoint,SetZenithAngelOffset,SetAzimuthAngelOffse,SetDistanceOffset,SetDistanceMax,SetDistanceMin,SetLerpSpeed}

var config ={}

func _process(delta):
	if(not config.has("cameraMode") or not config.has("cameraSubMode")):
		return false
	
	match config.cameraMode:
		CameraMode.Protagonist:
			ProtagonistProcess(delta)

#region 外部方法
func SetMode(mode):
	if(not Check(mode,CheckType.SetMode)):
		return
	config.cameraMode = mode

	#Set default "Common Config" if it is null
	if(not config.has("isLerp")):
		config.isLerp=true
		config.lerpSpeed=0.5
	if(not config.has("projectionMode")):
		config.projectionMode=ProjectionMode.Perspective

func SetSubMode(subMode):
	if(not Check(subMode,CheckType.SetSubMode)):
		return 
	config.cameraSubMode=subMode
	match subMode :
			ProtagonistMode.Circle:
				config.distanceMin = 15.0
				config.distanceMax = 100.0
				config.distanceOffset = 0.0

				config.zenithAngelOffset = 0.0	
				config.azimuthAngelOffset = 0.0	

				config.isAutoSurround = false
				config.autoSurroundSpeed = 30.0
				config.lookAtTargetType = LookAtTargetType.Vector3Point

func SetLookAtTargetType(value:int):
	config.lookAtTargetType=value

func SetLookAtSpatial(traget:Spatial):
	if (not Check(traget,CheckType.SetLookAtSpatial)):
		return

	config.lookAtSpatial=traget

func SetLookAtPoint(traget:Vector3):
	if (not Check(traget,CheckType.SetLookAtPoint)):
		return
	config.lookAtPoint=traget

func SetZenithAngelOffset(value:float):
	if (not Check(value,CheckType.SetZenithAngelOffset)):
		return
	#TODO: 约束到01之间
	config.zenithAngelOffset = value

func SetAzimuthAngelOffse(value:float):
	if (not Check(value,CheckType.SetAzimuthAngelOffse)):
		return
	#TODO: 约束到01之间
	config.azimuthAngelOffset = value

func SetDistanceOffset(value:float):
	if (not Check(value,CheckType.SetDistanceOffset)):
		return
	#TODO: 约束到01之间
	config.distanceOffset = value

func SetDistanceMax(value:float):
	if (not Check(value,CheckType.SetDistanceMax)):
		return

	config.distanceMax = value

func SetDistanceMin(value:float):
	if (not Check(value,CheckType.SetDistanceMin)):
		return

	config.distanceMin = value

func SetLerp(value:bool):
	config.isLerp=value

func SetLerpSpeed(value:float):
	if (not Check(value,CheckType.SetLerpSpeed)):
		return

	config.lerpSpeed=value
#end 外部方法

#region 内部方法(不要在外部调用这些方法)
func ProtagonistProcess(delta):
	if not config.has("lookAtSpatial") and not config.has("lookAtPoint"):
		return
	
	match config.cameraSubMode :
		ProtagonistMode.Circle:
			var distance = float((config.distanceMax-config.distanceMin)*config.distanceOffset)+config.distanceMin
			var zenithAngel = config.zenithAngelOffset*3.14 #(极角)
			var azimuthAngel = config.azimuthAngelOffset*2*3.14 #(方位角)

			var targetPosition

			if(config.lookAtTargetType==LookAtTargetType.SpatialNode):
				targetPosition=config.lookAtSpatial.transform.origin
			else:
				targetPosition=config.lookAtPoint
			
			var cameraPosition = Vector3(targetPosition.x+distance*sin(zenithAngel)*cos(azimuthAngel),
			targetPosition.y+distance*cos(zenithAngel),targetPosition.z+distance*sin(zenithAngel)*sin(azimuthAngel))


			if(config.isLerp):
				LookAtPositionLerp(cameraPosition,targetPosition)
			else:
				LookAtPosition(cameraPosition,targetPosition)

func Check(input,checkType)->bool:
	if(input == null):
		print("CameraControllerError: set parameter can not be null")
		return false
	match checkType:

		CheckType.SetMode:
			#if new mode == current mode , just return
			if(config.has("cameraMode") and config.cameraMode == input):
				print("CameraControllerWarn: new mode == current mode, nothing changed!")
				return false

		CheckType.SetSubMode:
			#if new subMode == current subMode , just return
			if(config.has("cameraSubMode") and config.cameraSubMode == input):
				print("CameraControllerWarn: new subMode == current subMode, nothing changed!")
				return false

		CheckType.SetLookAtTargetType:
			if(not config.has("cameraMode")):
				print("CameraControllerError: you have to set mode Protagonist first")
				return false
			elif(config.cameraMode !=CameraMode.Protagonist):
				print("CameraControllerError: function SetLookAtTargetType() can be called only under mode Protagonist")
				return false

		CheckType.SetLookAtSpatial:
			if(not config.has("cameraMode")):
				print("CameraControllerError: you have to set mode Protagonist first")
				return false
			elif(config.cameraMode !=CameraMode.Protagonist):
				print("CameraControllerError: function SetLookAtSpatial() can be called only under mode Protagonist")
				return false
			elif(config.lookAtTargetType==LookAtTargetType.Vector3Point):
				print("CameraControllerError: function SetLookAtSpatial() can be called only under LookAtTargetType=SpatialNode")
				return false

		CheckType.SetLookAtPoint:
				if(not config.has("cameraMode")):
					print("CameraControllerError: you have to set mode Protagonist first")
					return false
				elif(config.cameraMode !=CameraMode.Protagonist):
					print("CameraControllerError: function SetLookAtPoint() can be called only under mode Protagonist")
					return false
				elif(config.lookAtTargetType==LookAtTargetType.SpatialNode):
					print("CameraControllerError: function SetLookAtSpatial() can be called only under LookAtTargetType=Vector3Point")
					return false

		CheckType.SetZenithAngelOffset:
			if(not config.has("cameraMode")):
				print("CameraControllerError: you have to set mode Protagonist first")
				return false
			elif(config.cameraMode !=CameraMode.Protagonist):
				print("CameraControllerError: function SetZenithAngelOffset() can be called only under mode Protagonist")
				return false

		CheckType.SetAzimuthAngelOffse:
			if(not config.has("cameraMode")):
				print("CameraControllerError: you have to set mode Protagonist first")
				return false
			elif(config.cameraMode !=CameraMode.Protagonist):
				print("CameraControllerError: function SetAzimuthAngelOffse() can be called only under mode Protagonist")
				return false

		CheckType.SetDistanceOffset:
			if(not config.has("cameraMode")):
				print("CameraControllerError: you have to set mode Protagonist first")
				return false
			elif(config.cameraMode !=CameraMode.Protagonist):
				print("CameraControllerError: function SetSurroundAngelOffset() can be called only under mode Protagonist")
				return false

		CheckType.SetDistanceMax:
			if(not config.has("cameraMode")):
				print("CameraControllerError: you have to set mode Protagonist first")
				return false
			elif(config.cameraMode !=CameraMode.Protagonist):
				print("CameraControllerError: function SetSurroundAngelOffset() can be called only under mode Protagonist")
				return false
			elif(input<0):
				print("CameraControllerError: function SetDistanceMax(value) can be called when value >=0")
				return false
			elif(input<config.distanceMin):
				print("CameraControllerError: fun50ction SetDistanceMax(value) can be called when DistanceMax >=DistanceMin")
				return false

		CheckType.SetDistanceMin:
			if(not config.has("cameraMode")):
				print("CameraControllerError: you have to set mode Protagonist first")
				return false
			elif(config.cameraMode !=CameraMode.Protagonist):
				print("CameraControllerError: function SetSurroundAngelOffset() can be called only under mode Protagonist")
				return false
			elif(input<0):
				print("CameraControllerError: function SetDistanceMin(value) can be called when value >=0")
				return false
			elif(input>config.distanceMax):
				print("CameraControllerError: function SetDistanceMin(value) can be called when DistanceMax >=DistanceMin")
				return false

		CheckType.SetLerpSpeed:
			if(input<=0 or input>1):
				print("CameraControllerError: function SetLerpSpeed(value) can be called when 1	>=value >0")
				return false


	return true

#不借助Spatial节点的look_at（）方法自己实现
func LookAt(taregtPosition,worldUp=Vector3.UP):
	var cameraAxis_Z =(transform.origin-taregtPosition).normalized()

	var cameraAxis_X= worldUp.cross(cameraAxis_Z).normalized()
	
	var cameraAxis_Y= cameraAxis_Z.cross(cameraAxis_X)
	
	transform.basis=Basis(cameraAxis_X,cameraAxis_Y,cameraAxis_Z)

func LookAtLerp(taregtPosition,worldUp=Vector3.UP):
	var cameraAxis_Z =(transform.origin-taregtPosition).normalized()

	var cameraAxis_X= worldUp.cross(cameraAxis_Z).normalized()
	
	var cameraAxis_Y= cameraAxis_Z.cross(cameraAxis_X)
	
	var quat = Quat(transform.basis).slerp( Quat(Basis(cameraAxis_X,cameraAxis_Y,cameraAxis_Z)),config.lerpSpeed) 

	transform.basis = Basis(quat)

#不借助Spatial节点的look_at_from_position（）方法自己实现
func LookAtPosition(position,taregtPosition,worldUp=Vector3.UP):
	transform.origin=position
	LookAt(taregtPosition,worldUp)

func LookAtPositionLerp(position,taregtPosition,worldUp=Vector3.UP):
	transform.origin= lerp(transform.origin,position,config.lerpSpeed)  
	LookAtLerp(taregtPosition,worldUp)
#end 内部方法
