extends BasicAction

class_name FlyAction


#贝塞尔插值数量，越大越平滑，但需要更多计算开销
const interpolationNum=32
#飞行高度
var fly_height=9
#飞行半径
var fly_range=8
#最大飞行速度
var max_fly_speed=3.5
#飞行加速度
var acceleration = 2

#扰动参数 
var disturbance_frequency=5
var disturbance_amplitude=100

var velocity
var startPosition
var pathNode  #用于修改路径
var pathFollowNode  #用于fellow路径
var point


enum FlyPhase {Up,Mill,Down,Ground}

onready var currentFlyPhase=FlyPhase.Up
onready var curves=Curve3D.new()

func run(data):
	.run(data)
	#记录起飞前的位置，最后需要回到i原点
	startPosition=parentNode.transform.origin 
	velocity = Vector3.ZERO
	#给父节点添加路径节点
	pathNode=Path.new()
	parentNode.add_child(pathNode)
	pathFollowNode=PathFollow.new()
	pathNode.add_child(pathFollowNode)
	#计算路径
	FlyPathCal()

func _physics_process(delta):
	match currentFlyPhase:
		FlyPhase.Up:
			
			move_along_path(delta)
			#如果飞行高度到达了fly_height
			
			if(pathFollowNode.unit_offset>0.98):
				print("ReachMaxHeight")
				currentFlyPhase=FlyPhase.Mill
				FlyPathCal()

		FlyPhase.Mill:
			move_along_path(delta)
			if(pathFollowNode.unit_offset>0.98):
				print("转了一圈")
				
		FlyPhase.Down:
			move_along_path(delta)
			print("Down")
			print(pathFollowNode.unit_offset)
			if(pathFollowNode.unit_offset>0.98):
				currentFlyPhase=FlyPhase.Ground
				print("Ground")
			pass
		_:
			pass
	

	#如果飞行中和任何东西发生了碰撞
	if(parentNode.is_on_wall()):
		print("is_on_wall")
		pass
func FlyPathCal():
	curves.clear_points( )
	match currentFlyPhase:
		FlyPhase.Up:
			#二次贝塞尔曲线插值需要的三个参数 p0已经有了
			var p1=Vector3(startPosition.x,startPosition.y+fly_height,startPosition.z)
			var p2=Vector3(startPosition.x+fly_range,startPosition.y+fly_height,startPosition.z)
			
			#二次贝塞尔曲线插值
			var t_delta=1.0/(interpolationNum+1)
			var t=t_delta
			curves.add_point(startPosition)
			for i in range(interpolationNum):
			
				point=_quadratic_bezier(startPosition,p1,p2,t)
				t+=t_delta
				curves.add_point(point)

			curves.add_point(p2)

		FlyPhase.Mill:
			var angel_delta= 6.28/(interpolationNum+1)   #3.14 *2 
			var angel=-6.28+angel_delta
			curves.add_point(parentNode.transform.origin)

			for i in range(interpolationNum):
				point =Vector3(startPosition.x+fly_range*cos(angel),startPosition.y+fly_height,startPosition.z+fly_range*sin(angel))
				angel+=angel_delta

				curves.add_point(point)
		FlyPhase.Down:
			#二次贝塞尔曲线插值需要的三个参数 p2已经有了
			var p0= parentNode.transform.origin
			var p1=Vector3(startPosition.x,startPosition.y+fly_height,startPosition.z)
			
			
			#二次贝塞尔曲线插值
			var t_delta=1.0/(interpolationNum+1)
			var t=t_delta
			curves.add_point(p0)
			for i in range(interpolationNum):
			
				point=_quadratic_bezier(p0,p1,startPosition,t)
				t+=t_delta
				curves.add_point(point)

			curves.add_point(startPosition)
#	GlobalImmediateGeometry_debug.create_line(curves.get_baked_points( ))
	pathNode.curve=curves
	pathFollowNode.unit_offset=0
	pass

func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r
func _cubic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var q2 = p2.linear_interpolate(p3, t)

	var r0 = q0.linear_interpolate(q1, t)
	var r1 = q1.linear_interpolate(q2, t)

	var s = r0.linear_interpolate(r1, t)
	return s
	
func move_along_path(delta):
	if(velocity.length()<max_fly_speed):
		velocity.y += acceleration * delta

	pathFollowNode.offset+=velocity.length()* delta
	
	velocity=(pathFollowNode.translation-parentNode.translation).normalized()* velocity.length()
	
	velocity=parentNode.move_and_slide(velocity)
func fly_to_ground():
	currentFlyPhase=FlyPhase.Down
	FlyPathCal()
