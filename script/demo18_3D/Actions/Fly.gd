extends BasicAction

class_name FlyAction

#region Export variable
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
#endregion	




#region Internal variable
enum FlyPhase {Up, Mill, Down, Ground}
var velocity
var startPosition
var pathNode  #用于修改路径
var pathFollowNode  #用于fellow路径
var point

onready var currentFlyPhase = FlyPhase.Up
onready var curves = Curve3D.new()
#endregion	

#region Public Method
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
	
func FlyToGround():
	currentFlyPhase=FlyPhase.Down
	FlyPathCal()
	
#endregion	

func _physics_process(delta):
	match currentFlyPhase:
		FlyPhase.Up:
			
			MoveAlongPath(delta)
			#如果飞行高度到达了fly_height
			
			if(pathFollowNode.unit_offset==1):
				currentFlyPhase=FlyPhase.Mill
				FlyPathCal()

		FlyPhase.Mill:
			MoveAlongPath(delta)

				
		FlyPhase.Down:
			MoveAlongPath(delta)
			if(pathFollowNode.unit_offset==1):
				currentFlyPhase=FlyPhase.Ground
		_:
			pass


func FlyPathCal():
	curves.clear_points( )
	match currentFlyPhase:
		FlyPhase.Up:
			pathFollowNode.loop=false
			#二次贝塞尔曲线插值需要的三个参数 p0已经有了
			var p1 = Vector3(startPosition.x,startPosition.y+fly_height,startPosition.z)
			var p2 = Vector3(startPosition.x+fly_range,startPosition.y+fly_height,startPosition.z)
			
			#二次贝塞尔曲线插值
			var t_delta=1.0/(interpolationNum+1)
			var t=t_delta
			curves.add_point(startPosition)
			for i in range(interpolationNum):
			
				point = QuadraticBezier(startPosition,p1,p2,t)
				t += t_delta
				curves.add_point(point)

			curves.add_point(p2)

		FlyPhase.Mill:
			pathFollowNode.loop=true
			var angel_delta= 6.28/(interpolationNum+1)   #3.14 *2 
			var angel=-6.28+angel_delta
			curves.add_point(parentNode.transform.origin)

			for i in range(interpolationNum):
				point =Vector3(startPosition.x+fly_range*cos(angel),startPosition.y+fly_height,startPosition.z+fly_range*sin(angel))
				angel+=angel_delta

				curves.add_point(point)
		FlyPhase.Down:
			pathFollowNode.loop=false
			#二次贝塞尔曲线插值需要的三个参数 p2已经有了
			var p0= parentNode.transform.origin
			var p1=Vector3(startPosition.x,startPosition.y+fly_height,startPosition.z)
			
			
			#二次贝塞尔曲线插值
			var t_delta=1.0/(interpolationNum+1)
			var t=t_delta
			curves.add_point(p0)
			for i in range(interpolationNum):
				point = QuadraticBezier(p0,p1,startPosition,t)
				t += t_delta
				curves.add_point(point)

			curves.add_point(startPosition)
	GlobalImmediateGeometry_debug.create_line(curves.get_baked_points( ))
	pathNode.curve=curves
	pathFollowNode.unit_offset=0
	pass

func QuadraticBezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r

func MoveAlongPath(delta):
	if(velocity.length()<max_fly_speed):
		velocity.y += acceleration * delta

	pathFollowNode.offset+=velocity.length()* delta
	
	velocity=(pathFollowNode.translation-parentNode.translation).normalized()* velocity.length()
	
	velocity=MoveParentNode(parentNode, velocity, delta)
	


func MoveParentNode(parentNode:Spatial, velocity, time:float):
	parentNode.transform.origin +=  velocity * time
	return velocity
