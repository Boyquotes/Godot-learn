extends BasicAction

class_name RotateAction





var rotateSpeed =15



func run(data):
	.run(data)
	pass

func _physics_process(delta):
	var rot_speed = rad2deg(rotateSpeed)  # rotateSpeed deg/sec
	parentNode.rotate_x(rot_speed*delta)
	pass


