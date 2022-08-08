extends PlayerState

func ready():
	stateManager.registerState(GlobalPlayer.State.SIT, self)

func enter(data_json):
	do_input(data_json)

func exit(data_json):
	pass

func get_substate():
	return "SitStart"
	
func get_stop_type():
	return GlobalPlayer.State.IDLE
	
func get_move_type():
	return GlobalPlayer.State.IDLE
	
func physics_process(data_json):
	
	var type = data_json["type"]
	
	if stateManager.inNodeTypes(type, [
			"Stand/Idle"
		]):
		stateManager.transformState(type)
		return
		
	if stateManager.inNodeTypes(type, [
			"Stand/Sit"
		]):
		do_input(data_json)
		return
		
func do_input(data_json):
	
	var curPosition = data_json["curPosition"]
	var curForward = data_json["curForward"]
	player.transform.origin =  curPosition
	player.set_rotation(curForward)
