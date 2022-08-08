extends PlayerState

var velocity: = Vector3.ZERO
var localJudge = 0

func ready():
	stateManager.registerState(GlobalPlayer.State.CREEP, self)

func enter(data_json):
	# 调整名字高度
	player.setPlayerNameHeight(5.3)
	pass
	
func exit(data_json):
	# 调整名字高度
	player.setPlayerNameHeight(5.3)
	pass
	
func get_stop_type():
	return player.flatType
	
func get_move_type():
	return GlobalPlayer.State.CREEP
	
func physics_process(data_json):
	var type = data_json["type"]

	if stateManager.inNodeTypes(type, [
			"Stand/Walk",
			"OnGround/Flat",
			"Stand/Idle"
		]):
		stateManager.transformState(type)
		return
		
	if stateManager.inNodeTypes(type, [
			"OnGround/Creep"
		]):
		do_input(data_json)
		return
	
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
#		var tmp_scale = player.scale
#		target_direction.basis = target_direction.basis.scaled(tmp_scale)
		player.transform = player.transform.interpolate_with(target_direction, info._rotation_speed_factor * delta)#方向
		velocity = calculate_velocity(velocity, input_direction, delta)
		velocity = player.move_and_slide(velocity, Vector3.UP)
	else:
		input_direction = input_direction.normalized()	
		input_direction.y = 0
		var target_direction: = player.transform.looking_at(player.global_transform.origin + input_direction, Vector3.UP)
#		var tmp_scale = player.scale
#		target_direction.basis = target_direction.basis.scaled(tmp_scale)
		player.transform = player.transform.interpolate_with(target_direction, info._rotation_speed_factor * delta)
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
