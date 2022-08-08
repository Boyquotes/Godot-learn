extends PlayerState
	
func ready():
	stateManager.registerState(GlobalPlayer.State.FLAT_01, self)
	stateManager.registerState(GlobalPlayer.State.FLAT_02, self)
	stateManager.registerState(GlobalPlayer.State.FLAT_03, self)

func enter(data_json):
	do_input(data_json)
	# 调整名字高度
	player.setPlayerNameHeight(2.3)
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
			"OnGround/Creep",
			"OnGround/Flat"
		]):
		stateManager.transformState(type)
		

func do_input(data_json):
	if info._isRobotAccount != "1" and data_json and "curPosition" in data_json:
		#NPC不校验位置
		player.global_transform.origin = data_json["curPosition"]
