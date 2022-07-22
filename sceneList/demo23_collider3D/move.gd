extends KinematicBody


onready var motion =Vector3(0,0,0)
onready var speed = 2

func move_and_slideas():
	pass
var i=0
func _physics_process(delta):
	motion =Vector3(0,0,0)
	if Input.is_action_pressed("ui_right"):
		motion.x = speed
		move_and_slide(motion, Vector3.UP)
	elif  Input.is_action_pressed("ui_left"):
		motion.x = -speed
		move_and_slide(motion, Vector3.UP)


