extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	print("bounce")
	var bounceObj= get_tree().root.find_node("cube", true, false)

	if(bounceObj!=null):
		var rig=bounceObj.find_node("RigidBody", true, false)
		if(rig !=null):
			
			pass

