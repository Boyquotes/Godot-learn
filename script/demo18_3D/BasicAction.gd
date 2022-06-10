class_name BasicAction
extends Node

var empty_data = {
	"state": true,
	"location": Vector3(0,0,0),
	"direction": Vector3(0,0,0)
}

signal input_activate(dict)
signal output_success(dict)

var parentNode

func _enter_tree():
	self.connect("input_activate", self, "run")
	
	
func run(data):
	parentNode=get_parent()

#	emit_signal("output_success")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

