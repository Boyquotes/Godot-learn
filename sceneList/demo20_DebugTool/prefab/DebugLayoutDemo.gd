# This script is meant to demonstrate how simple it is to use the scripts in the
# debug helper

extends Node
#UI maker script
var debugUIMaker = preload("res://sceneList/demo20_DebugTool/scripts/DebugUIMaker.gd")
#UI theme
var labelFontTheme=load("res://sceneList/demo20_DebugTool/prefab/font/fontLabel.tres")
var titleFontTheme=load("res://sceneList/demo20_DebugTool/prefab/font/fontTitle.tres")
var logFontTheme=load("res://sceneList/demo20_DebugTool/prefab/font/fontLog.tres")
var emptyStyleBoxTheme=load("res://sceneList/demo20_DebugTool/prefab/theme/stylebox_empty.tres")


var debugUI

#region Debug Variable Define
var variableDict={}

#end region

func _enter_tree()-> void:

	debugUI=Control.new()
	debugUI.set_script(debugUIMaker)
	debugUI.SetTheme(labelFontTheme,titleFontTheme,logFontTheme,emptyStyleBoxTheme)
	add_child(debugUI)
	
	debugUI.SetVisibility(true)   #Default is Invisible,uncomment this to set it visible

func _physics_process(_dt: float) -> void:
	debugUI.AddTitle("system","System:")

	# Show the frames per second
	debugUI.AddLabel("fps_physicsfps", "FPS: %s" % Engine.get_frames_per_second() +"      Physics: %s/s" % Engine.iterations_per_second)

	debugUI.AddLabel("memory","Video Mem Usage(texture and vertex): %s" % str(Performance.get_monitor(20)/1024/1024)+" MB")
	
	debugUI.AddLabel("winsize_vsync", "Window Size: %s" % OS.get_window_size()+"      VSync: %s" % OS.vsync_enabled)

	debugUI.AddLabel("objcte", "Object Count: %s" % Performance.get_monitor(8)+"      Orphan Node: %s" % Performance.get_monitor(11))

	debugUI.AddLabel("render","Render Object: %s"% Performance.get_monitor(12)+"      Render Vectices: %s" % Performance.get_monitor(13)+"      Draw Call: %s" % Performance.get_monitor(17))
	
	debugUI.AddLabel("shader","Shader Change: %s"% Performance.get_monitor(15)+"      Material CHange: %s" % Performance.get_monitor(14))
	
	debugUI.AddTitle("variable","Variable:")
	
	for key in variableDict.keys():
		debugUI.AddLabel(key,str(key)+": "+str(variableDict[key]))

func DebugPrint(msg:String):
	print(msg)
	debugUI.AddTitle("log","Debug Print:")
	debugUI.AddTextArea("textArea_0",msg,600,false)

func NetworkPrint(msg:String):
	print(msg)
	debugUI.AddTitle("network","Network Print:")
	debugUI.AddTextArea("textArea_1",msg,600,true)
	
func _input(event):
	if event is InputEventScreenTouch and event.pressed == true and event.index==4:
		debugUI.SetVisibility(!debugUI.isVisible)

func Clear():
	debugUI.Clear()
