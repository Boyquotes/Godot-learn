extends Node


var UnItemSelected = preload("res://sceneList/demo25_MusicUI/ItemUnSelected.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	var item = UnItemSelected.instance()
	item.SetContent("content")
	item.SetId ("id")
	self.add_child(item)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
