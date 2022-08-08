extends Node
class_name PlayerState

#onready var model : Model
onready var player : Player
onready var info : Info
onready var stateManager
onready var playerManger

func _ready() -> void:
	yield(owner, "ready")
	player = owner
	info = player.get_node("Info")
	stateManager = player.get_node("StateManager")
	playerManger = player.get_parent()
	ready()

func ready():
	pass
	
func enter(data_json):
	pass

func exit(data_json):
	pass

func process(delta):
	pass

func physics_process(data_json):
	pass
	
func get_stop_type():
	return null
	
func get_move_type():
	return null
	
func get_substate():
	return null
	
func calculate_velocity(  # 用于计算速度 主要是计算跳跃反向的速度
		velocity_current: Vector3,
		move_direction: Vector3,
		delta: float
	) -> Vector3:
		var velocity_new := move_direction * info._move_speed
#		if velocity_new.length() > max_speed:
#			velocity_new = velocity_new.normalized() * max_speed
		velocity_new.y = velocity_current.y  + info._gravity * delta
		if(velocity_new.x != 0):
#			print("velocity_new  ",velocity_new)
			pass
		return velocity_new
