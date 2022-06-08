

class_name Enemy
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var name
func _init(name):
	print("Enemy init")
	self.name=name
	pass

func Attack(type):
	print("Enemy attack"+type)
func ShowName():
	print(name)
