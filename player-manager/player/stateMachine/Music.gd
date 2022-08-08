extends AudioStreamPlayer

func _ready():
	self.connect("finished", self, "stopMusic")

func _switchMusic(type : int):
	self.stop()
	var animation = get_parent().get_node("AnimationModel").animation
	if not type in animation:
		return
	var typeInfo = animation[type]
	if not "music" in typeInfo or not "source" in typeInfo["music"]:
		return
	var source = typeInfo["music"]["source"]
	if "loop" in typeInfo["music"]:
		var loop = typeInfo["music"]["loop"]
		source.set_loop(loop)
	stream = source
	self.play()
	
func stopMusic():
	self.stop()
