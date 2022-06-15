extends BasicAction

class_name RotateAction

enum RoatateAxis{X,Y,Z}

#旋转速度
var rotateSpeed =5
#旋转轴
var Axis=RoatateAxis.Y


func run(data):
	.run(data)
	pass

func _physics_process(delta):
	var rot_speed = rad2deg(rotateSpeed)  # rotateSpeed deg/sec
	
	match Axis:
		RoatateAxis.X:
			parentNode.rotate_x(rot_speed*delta)
		RoatateAxis.Y:
			parentNode.rotate_y(rot_speed*delta)
		RoatateAxis.Z:
			parentNode.rotate_z(rot_speed*delta)
	pass


