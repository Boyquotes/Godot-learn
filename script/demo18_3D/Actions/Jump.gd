extends BasicAction

class_name JumpAction

var velocity
var parentNode
var jump_impulse

var max_jump_impulse=20
var fall_acceleration = 30


func run(data):
	parentNode=get_parent()
	jump_impulse=max_jump_impulse
	velocity = Vector3.ZERO
	pass

func _physics_process(delta):

	if(parentNode.is_on_floor()):

		velocity.y += jump_impulse
		jump_impulse=jump_impulse*0.7
		if(jump_impulse<0.5):
			jump_impulse=max_jump_impulse
		
	velocity.y -= fall_acceleration * delta
	velocity=parentNode.move_and_slide(velocity, Vector3.UP)


