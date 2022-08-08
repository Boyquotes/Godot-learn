extends PlayerState

var velocity: = Vector3.ZERO
#var localJudge = 0

func ready():
	stateManager.registerState(GlobalPlayer.State.FLY, self)
	
func get_stop_type():
	return GlobalPlayer.State.FLY
	
func get_move_type():
	return GlobalPlayer.State.FLY
	
func enter(data_json):
	pass

func exit(data_json):
	pass

func physics_process(data_json):
	var type = data_json["type"]
	
	if stateManager.inNodeTypes(type, []):
		stateManager.transformState(type)
		return
		
	if stateManager.inNodeTypes(type, [
			"InSky/Fly",
		]):
		do_input(data_json)
		return

func do_input(data_json):
	var input_direction = data_json["curForward"]
	var curPosition = data_json["curPosition"]
	var delta = data_json["delta"]
	input_direction = input_direction.normalized()	
	input_direction = Vector3(input_direction.x, input_direction.z, 0)
	var target_direction: = player.transform.looking_at(player.global_transform.origin + input_direction, Vector3.UP)
	var tmp_scale = player.scale
#		target_direction.basis = target_direction.basis.scaled(tmp_scale)
	player.transform = player.transform.interpolate_with(target_direction, info._rotation_speed_factor * delta)
	player.scale = tmp_scale
	velocity = calculate_velocity(velocity, input_direction, delta)
	velocity = player.move_and_slide(velocity, Vector3.UP)

# 用于计算速度 主要是计算跳跃反向的速度 计算Y轴位置
func calculate_velocity(velocity_current: Vector3,move_direction: Vector3,delta: float) -> Vector3:
		var velocity_new := move_direction * info._move_speed
		velocity_new.y = velocity_new.y #+ info._gravity * delta
		print(velocity_new)
		return velocity_new
