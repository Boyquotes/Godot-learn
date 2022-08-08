extends PlayerState
var tween
var aimPosition = Vector3.UP
var middlePosition = Vector3.UP
var jumpTime = 0.8
func ready():
	stateManager.registerState(GlobalPlayer.State.JUMP, self)
	
func enter(data_json):
	var type = data_json["type"]
	if(type == GlobalPlayer.State.JUMP):
		aimPosition = data_json["curPosition"]
		middlePosition = Vector3(
			(player.transform.origin.x+aimPosition.x)*0.5,
			(player.transform.origin.y+aimPosition.y)*0.5+15,
			(player.transform.origin.z+aimPosition.z)*0.5)
		
		if tween == null:
			tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(player, "translation",
		player.transform.origin, middlePosition,
		jumpTime,Tween.TRANS_LINEAR,Tween.EASE_IN)
		tween.start()
		tween.interpolate_callback(self,jumpTime,"tweenEndCallBack")
	pass

func exit(data_json):
	pass
	

func physics_process(data_json):
		
	pass

func tweenEndCallBack():
#	
	tween.interpolate_property(player, "translation",
		middlePosition, aimPosition,
		jumpTime,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	tween.interpolate_callback(self,jumpTime,"tweenEndCallBack2")
	
	pass
func tweenEndCallBack2():
	stateManager.transformState(GlobalPlayer.State.IDLE)
	pass
