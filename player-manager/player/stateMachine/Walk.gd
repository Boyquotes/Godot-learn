extends PlayerState

var velocity: = Vector3.ZERO
var forceStop = true
#var localJudge = 0

func ready():
	stateManager.registerState(GlobalPlayer.State.WALK, self)
	
func get_stop_type():
	return GlobalPlayer.State.IDLE
	
func get_move_type():
	return GlobalPlayer.State.WALK
	
func enter(data_json):
	pass

func exit(data_json):
	pass

func process(delta):
	if walk or forceStop:
		return
	# 滑行结束自动切idle
	if velocity.length() <= 0.3:
		stateManager.transformState(GlobalPlayer.State.IDLE)
		return
	velocity.y = velocity.y  + info._gravity * delta
	velocity.x = lerp(velocity.x, 0, info._friction * delta)
	velocity.z = lerp(velocity.z, 0, info._friction * delta)
	velocity = player.move_and_slide(velocity, Vector3.UP)
	
var walk = true
func physics_process(data_json):
	var type = data_json["type"]
	
	if stateManager.inNodeTypes(type, [
		"Stand/Walk",
		]):
		walk = true
		forceStop = isForceStop()
		do_input(data_json)
		return
			
	walk = false
	
	if forceStop:
		
		if stateManager.inNodeTypes(type, [
				"OnGround/Flat",
				"Stand/Jump",
				"Stand/Idle"
			]):
			stateManager.transformState(type)
			return
	else:
		# 手离开遥感后滑行过程中收到oneshot可正常处理
		if stateManager.inNodeTypes(type, [
				"OneShot"
			]):
			stateManager.transformState(type)
			return
		
func isForceStop():
	return info._forceStop
		
func get_substate():
	# 由坐着变成idle会先执行动画树中的SitUp
	if stateManager.stateAnimation[GlobalPlayer.State.WALK] == "103_Walk_Glide":
		return "SkateStart"
	return null
	
		
func do_input(data_json):
	var input_direction = data_json["curForward"]
	var curPosition = data_json["curPosition"]
#	var nextForward = data_json["nextForward"]
	var delta = data_json["delta"]

	if info._isSelfPlayer and NavigatorTool.pacmanNetworkModel == false:     # 有相机 即自己
		input_direction = input_direction.normalized()	
		input_direction.y = 0
		player._move_direction = input_direction
		var target_direction: = player.transform.looking_at(player.global_transform.origin + input_direction, Vector3.UP)
		var tmp_scale = player.scale
#		target_direction.basis = target_direction.basis.scaled(tmp_scale)
		player.transform = player.transform.interpolate_with(target_direction, info._rotation_speed_factor * delta)#方向
		player.scale = tmp_scale
		velocity = calculate_velocity(velocity, input_direction, delta)
		velocity = player.move_and_slide(velocity, Vector3.UP)
	else:
		input_direction = input_direction.normalized()	
		input_direction.y = 0
		var target_direction: = player.transform.looking_at(player.global_transform.origin + input_direction, Vector3.UP)
		var tmp_scale = player.scale
#		target_direction.basis = target_direction.basis.scaled(tmp_scale)
		player.transform = player.transform.interpolate_with(target_direction, info._rotation_speed_factor * delta)
		player.scale = tmp_scale
		velocity = calculate_velocity(velocity, input_direction, delta)
		velocity = player.move_and_slide(velocity, Vector3.UP)
		if(player.playerinfo._isRobotAccount != "1"):#NPC不校验位置
#			print("length=====",(data_json["curPosition"]- player.transform.origin).length())
			if((data_json["curPosition"]- player.transform.origin).length()>0.7 and NavigatorTool.pacmanNetworkModel == false):
				player.global_transform.origin = data_json["curPosition"]



# 用于计算速度 主要是计算跳跃反向的速度 计算Y轴位置
func calculate_velocity(velocity_current: Vector3,move_direction: Vector3,delta: float) -> Vector3:
		var velocity_new := move_direction * info._move_speed
		velocity_new.y = velocity_current.y  + info._gravity * delta
		return velocity_new
