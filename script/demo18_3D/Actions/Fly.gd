extends BasicAction

class_name FlyAction


#贝塞尔插值数量，越大越平滑，但需要更多计算开销
const interpolationNum=8
#飞行高度
var flyHeight=9
#飞行半径
var flyRange=8
#最大飞行速度
var maxFlySpeed=3.5
#飞行加速度
var acceleration = 2
# 两端路径平滑交接比例 
var smoothJoin =0.88

#扰动参数 
var disturbance_frequency=5
var disturbance_amplitude=100

var velocity
var startPosition
var pathNode  #用于修改路径
var pathFollowNode  #用于fellow路径
var point
var curvesCurrentPoint

enum FlyPhase {Up,Mill,Down,Ground}

onready var currentFlyPhase=FlyPhase.Up
onready var curves=Curve3D.new()
onready var curvesSmoothJoin=Curve3D.new()
onready var isInSmoothJoin=false
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
	FlyPathCal(FlyPhase.Up)
	FlyPathSet(curves)
func _physics_process(delta):
	match currentFlyPhase:
		FlyPhase.Up:
			moveAlongPath(delta)
			#如果飞行高度到达了fly_height
			if(pathFollowNode.unit_offset>smoothJoin and not isInSmoothJoin):

				isInSmoothJoin=true
				FlyPathCal(FlyPhase.Mill)
				SmoothJoinPathCal()

				FlyPathSet(curvesSmoothJoin)
			elif(pathFollowNode.unit_offset>0.99):
				isInSmoothJoin=false
				currentFlyPhase=FlyPhase.Mill
				FlyPathSet(curves,true)
		FlyPhase.Mill:
			moveAlongPath(delta)
			if(pathFollowNode.unit_offset>smoothJoin):
				print("转了一圈")
				
		FlyPhase.Down:
			moveAlongPath(delta)
			print("Down")
			print(pathFollowNode.unit_offset)
			if(pathFollowNode.unit_offset>smoothJoin):
				currentFlyPhase=FlyPhase.Ground
				print("Ground")
			pass
		_:
			pass
	

	#如果飞行中和任何东西发生了碰撞
	if(parentNode.is_on_wall()):
		print("is_on_wall")
		pass
func FlyPathSet(targetCurve,removeFirst=false):

	curvesCurrentPoint=targetCurve.get_baked_points()
	if removeFirst:
		targetCurve.remove_point(0)
		
	pathNode.curve=targetCurve
	pathFollowNode.unit_offset=0

func FlyPathCal(FlyPhase):
	curves.clear_points( )
	match FlyPhase:
		0:
			#二次贝塞尔曲线插值需要的三个参数 p0已经有了
			var p1=Vector3(startPosition.x,startPosition.y+flyHeight,startPosition.z)
			var p2=Vector3(startPosition.x+flyRange,startPosition.y+flyHeight,startPosition.z)
			
			#二次贝塞尔曲线插值
			var t_delta=1.0/(interpolationNum+1)
			var t=t_delta
			curves.add_point(startPosition)
			for i in range(interpolationNum):
			
				point=quadraticBezier(startPosition,p1,p2,t)
				t+=t_delta
				curves.add_point(point)
			curves.add_point(p2)

		1:
			var angel_delta= 6.28/(interpolationNum+1)   #3.14 *2 
			var angel=-6.28+angel_delta
			curves.add_point(parentNode.transform.origin)

			for i in range(interpolationNum):
				point =Vector3(startPosition.x+flyRange*cos(angel),startPosition.y+flyHeight,startPosition.z+flyRange*sin(angel))
				angel+=angel_delta

				curves.add_point(point)
		2:
			#二次贝塞尔曲线插值需要的三个参数 p2已经有了
			var p0= parentNode.transform.origin
			var p1=Vector3(startPosition.x,startPosition.y+flyHeight,startPosition.z)
			
			
			#二次贝塞尔曲线插值
			var t_delta=1.0/(interpolationNum+1)
			var t=t_delta
			curves.add_point(p0)
			for i in range(interpolationNum):
			
				point=quadraticBezier(p0,p1,startPosition,t)
				t+=t_delta
				curves.add_point(point)

			curves.add_point(startPosition)
#	GlobalImmediateGeometry_debug.create_line(curves.get_baked_points( ))

	pass

func quadraticBezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r
func cubicBezier(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var q2 = p2.linear_interpolate(p3, t)

	var r0 = q0.linear_interpolate(q1, t)
	var r1 = q1.linear_interpolate(q2, t)

	var s = r0.linear_interpolate(r1, t)
	return s
	
func moveAlongPath(delta):
	if(velocity.length()<maxFlySpeed):
		velocity.y += acceleration * delta

	pathFollowNode.offset+=velocity.length()* delta
	
	velocity=(pathFollowNode.translation-parentNode.translation).normalized()* velocity.length()
	
	velocity=parentNode.move_and_slide(velocity)
func SmoothJoinPathCal():
	#用Cubic Bezie平滑当前路径和下一段路径
	curvesSmoothJoin.clear_points()
	var p0=parentNode.translation
	var p1=curvesCurrentPoint[-1]
	var p2=curves.get_baked_points()[0]
	var p3=curves.get_baked_points()[1]

	var t_delta=1.0/(interpolationNum+1)
	var t=t_delta
	curvesSmoothJoin.add_point(p0)
	for i in range(interpolationNum/2):
		point =cubicBezier(p0,p1,p2,p3,t)
		t+=t_delta
		curvesSmoothJoin.add_point(point)
	curvesSmoothJoin.add_point(p3)
	
func flyToGround():
	currentFlyPhase=FlyPhase.Down
	FlyPathCal(FlyPhase.Down)
