extends PlayerState

func ready():
	stateManager.registerState(GlobalPlayer.State.IDLE, self)

func enter(data_json):
	do_input(data_json)
	pass

func exit(data_json):
	pass
	
func get_stop_type():
	return GlobalPlayer.State.IDLE
	
func get_move_type():
	return GlobalPlayer.State.WALK

func get_substate():
	# 由坐着变成idle会先执行动画树中的SitUp
	if stateManager._currentType == GlobalPlayer.State.SIT:
		return "SitUp"
	return null
	
func physics_process(data_json):
	
	var type = data_json["type"]
	
	# 前置动画执行过程不处理输入
	var playback:AnimationNodeStateMachinePlayback = stateManager._animationModel.animationTree.get("parameters/StateMachine/Stand/playback")
	if stateManager.isEnableAnimation() and playback.get_current_node() != "Idle":
		return
	
	if stateManager.inNodeTypes(type, [
			"Sit/Sit",
			"OnGround/Flat",
			"Stand/Walk",
			"OneShot",
			"InSky/Fly",
			"Stand/UpJump",
		]):
		stateManager.transformState(type)
		return
		
	if stateManager.inNodeTypes(type, [
			"Stand/Idle"
		]):
		stateManager.transitAnimation(type)
		do_input(data_json)
		return
	
	
func do_input(data_json):
	
	if info._isRobotAccount != "1" and data_json and "curPosition" in data_json:
		#NPC不校验位置
		player.global_transform.origin = data_json["curPosition"]
