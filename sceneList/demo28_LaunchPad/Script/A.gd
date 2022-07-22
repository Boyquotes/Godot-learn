extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var audioStream :AudioStream= load("res://sceneList/demo28_LaunchPad/Audio/loop/fast/A1.wav")

	self.set_stream(audioStream)
	self.set_volume_db(3.0)
	play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
