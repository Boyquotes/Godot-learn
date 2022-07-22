extends Node



var collisionListener=load("res://sceneList/demo23_collider3D/collisionListener.gd")



func _ready():
	$cube2.set_script(collisionListener)
	$cube2.set_physics_process(true)
	# $cube2.SetCallback(funcref(self,"Callback"))

func Callback(input):
	print("Callback called")
	print(input.name)
	pass
