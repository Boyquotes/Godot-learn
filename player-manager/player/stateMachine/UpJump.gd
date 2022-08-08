extends PlayerState

var animationPlayer
var velocity
var inputControl

func ready():
	stateManager.registerState(GlobalPlayer.State.UPJUMP, self)

func enter(data_json):
	velocity = Vector3.ZERO
	inputControl = false
	animationPlayer = AnimationPlayer.new()
	var animation = Animation.new()
	var index = animation.add_track(Animation.TYPE_BEZIER)
	animation.length = 2.5
	animation.track_set_path(index, "../UpJump:velocity:y")
	animation.bezier_track_insert_key(index, 0, 0, Vector2(0,0), Vector2(0,0))
	animation.bezier_track_insert_key(index, 1, 20, Vector2(0,0.3), Vector2(0,0.3))
	animation.bezier_track_insert_key(index, 2, 0, Vector2(0,0), Vector2(0,0))
	index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(index, "../UpJump:inputControl")
	animation.track_insert_key(index, 1, true)
	animation.track_insert_key(index, 1.5, false)
	animationPlayer.add_animation("upjump", animation)
	animationPlayer.connect("animation_finished", self, "_on_animation_finished")
	animationPlayer.play("upjump")
	add_child(animationPlayer)
	
	
func _on_animation_finished(anim):
	stateManager.transformState(GlobalPlayer.State.IDLE)
	
func exit(data_json):
	remove_child(animationPlayer)
	animationPlayer = null
	
func get_move_type():
	return GlobalPlayer.State.UPJUMP
	
func process(delta):
	velocity.y = velocity.y  + info._gravity * delta
	velocity.x = lerp(velocity.x, 0, info._friction * delta)
	velocity.z = lerp(velocity.z, 0, info._friction * delta)
	velocity = player.move_and_slide(velocity, Vector3.UP)
	
func physics_process(data_json):
	var type = data_json["type"]
	
	if stateManager.inNodeTypes(type, [
			"Stand/UpJump",
		]):
		if inputControl:
			do_input(data_json)
			return
		
var input_direction
	
func do_input(data_json):
	input_direction = data_json["curForward"]
	print(input_direction)
	var delta = data_json["delta"]
	input_direction = input_direction.normalized()
	input_direction.y = 0
	var target_direction: = player.transform.looking_at(player.global_transform.origin + input_direction, Vector3.UP)
	var tmp_scale = player.scale
	player.transform = player.transform.interpolate_with(target_direction, info._rotation_speed_factor * delta)
	player.scale = tmp_scale
	velocity = calculate_velocity(velocity, input_direction, delta)
	velocity = player.move_and_slide(velocity, Vector3.UP)


func calculate_velocity(velocity_current: Vector3,move_direction: Vector3,delta: float) -> Vector3:
	var velocity_new := move_direction * info._move_speed
	return velocity_new
