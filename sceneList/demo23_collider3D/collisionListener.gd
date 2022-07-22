extends StaticBody

var callback:FuncRef

func SetCallback(function:FuncRef):
	callback=function

func _init():
	# MakeAaea()
	pass

#func _physics_process(delta):
#	print("1232")

# func onBodyEntered(input):
# 	if(input.name!=name  and callback!=null):
# 		callback.call_func(input)

# func MakeAaea():
# 	var collisionShapeNode=find_node("CollisionShape")
# 	var area = Area.new()
# 	area.monitoring=true
# 	var collisionShape = CollisionShape.new()
# 	collisionShape.shape = collisionShapeNode.shape
# 	collisionShape.transform = collisionShapeNode.transform
# 	collisionShape.scale.y = collisionShape.scale.y *1.1
# 	collisionShape.scale.z = collisionShape.scale.z *1.1
# 	collisionShape.scale.x = collisionShape.scale.x *1.1
# 	area.add_child(collisionShape)
# 	add_child(area)
# 	area.connect("body_entered",self,"onBodyEntered")
