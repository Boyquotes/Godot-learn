# This script is meant to demonstrate how simple it is to use the scripts in the
# debug helper

extends Node

var overlayDebugInfoScene = preload("res://sceneList/demo20_DebugTool/prefab/debugLayer.tscn")
var overlayDebugInfo

func _ready() -> void:
	overlayDebugInfo= overlayDebugInfoScene.instance()
	add_child(overlayDebugInfo)
	overlayDebugInfo.set_visibility(true)

var i=0

func _physics_process(_dt: float) -> void:
	# Show the frames per second
	overlayDebugInfo.set_label("fps", "FPS: %s" % Engine.get_frames_per_second())
	# Show number of physics iterations per second
	overlayDebugInfo.set_label("physicsfps", "Physics: %s/s" % Engine.iterations_per_second)
	# Show VSync setting "on/off"
	
	overlayDebugInfo.set_line("line_0")
	overlayDebugInfo.set_label("vsync", "VSync: %s" % OS.vsync_enabled)
	# Show window size
	overlayDebugInfo.set_label("winsize", "Window Size: %s" % OS.get_window_size())
	# Show window position
	overlayDebugInfo.set_label("winpos", "Window Position: %s" % OS.get_window_position())
	overlayDebugInfo.set_line("line_1")

	i+=1
	if(i==60):
		overlayDebugInfo.setTextArea("textArea_0","debug infomation nfomation compnfomation compnfomation comp compr_str")
		i=0
