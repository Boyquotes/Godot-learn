extends KinematicBody


var velocity = Vector3()

const speed = 6
const fall_acceleration = 3


export(NodePath) var cameraPath

var camera
func _ready():
	pass # Replace with function body.
	camera = get_node(cameraPath)


func _input(event):   
	if event is InputEventMouseMotion:

		camera.zenithAngelOffset += event.relative.y / 3500.0
		camera.azimuthAngelOffset += event.relative.x / 3500.0
		
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				camera.distanceOffset -= 0.05
				# call the zoom function
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				 camera.distanceOffset += 0.05
func _physics_process(delta):
	

	
	var dir = Vector3()
	
	if(Input.is_action_pressed("move_up")):
		dir += -camera.global_transform.basis[2]
	if(Input.is_action_pressed("move_down")):
		dir += camera.global_transform.basis[2]
	if(Input.is_action_pressed("move_left")):
		dir += -camera.global_transform.basis[0]
	if(Input.is_action_pressed("move_right")):
		dir += camera.global_transform.basis[0]
		
	if dir != Vector3.ZERO:
		dir = dir.normalized()

 # Ground velocity
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	# Vertical velocity
	velocity.y -= fall_acceleration * delta
	# Moving the character
	velocity = move_and_slide(velocity, Vector3.UP)
