extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var filePath = "C:/Users/xmyci/Desktop/doubleU/node-core/sceneList/zone0005_disco/audio/node-core.mp4"

# Called when the node enters the scene tree for the first time.
func _ready():
	var videoStreamGDNative = VideoStreamGDNative.new()
	videoStreamGDNative.set_file(filePath)
	var video = 	videoStreamGDNative.get_file()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
