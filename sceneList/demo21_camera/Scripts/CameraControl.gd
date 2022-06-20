extends Spatial

enum CameraMode {Protagonist,FreeLook}
enum ProtagonistMode{Circle, Sphere}
enum FreeLookMode{OnPlane}

enum ProjectionMode{Perspective , Orthogonal}


func _ready():
	pass # Replace with function body.


func SetCamera(config:Dictionary):
#	configDict.cameraMode=CameraOption.get_selected_id()
#	configDict.lookAtObj= objects[LookAtOption.get_selected_id()]
#	configDict.followObj = objects[FollowOption.get_selected_id()]
#	configDict.projectionMode = ProjectionOption.get_selected_id()
	
#	look_at(config.lookAtObj.transform.origin,Vector3.UP)
#	LookAt(config.lookAtObj.transform.origin,Vector3.UP)
	
#	look_at_from_position(Vector3(2,2,2),config.lookAtObj.transform.origin,Vector3.UP)
	LookAtPosition(Vector3(2,2,2),config.lookAtObj.transform.origin)

#不借助Spatial节点的look_at（）方法自己实现
func LookAt(taregtPosition,worldUp=Vector3.UP):
	var cameraAxis_Z =(transform.origin-taregtPosition).normalized()

	var cameraAxis_X= worldUp.cross(cameraAxis_Z).normalized()
	
	var cameraAxis_Y= cameraAxis_Z.cross(cameraAxis_X)
	
	transform.basis=Basis(cameraAxis_X,cameraAxis_Y,cameraAxis_Z)

#不借助Spatial节点的look_at_from_position（）方法自己实现
func LookAtPosition(position,taregtPosition,worldUp=Vector3.UP):
	transform.origin=position
	LookAt(taregtPosition,worldUp)
