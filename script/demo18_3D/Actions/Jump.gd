extends BasicAction

class_name JumpAction

#最大的起跳力度
var maxJumpImpulse=20
#下落重力加速度
var fallAcceleration = 30
#每次落地弹跳力度损失百分比为1-impulseLoss
var impulseLoss=0.7
#如果下次起跳的力度小于这个值则把起跳力度重置
var minJumpImpulse=0.5


onready var velocity = Vector3.ZERO
onready var jumpImpulse=maxJumpImpulse
func run(data):
	.run(data)
	pass

func _physics_process(delta):
	#如果落地，重新给一个向上的力，这个力每次落地会按百分比衰减，当这个力衰减小于minJumpImpulse时，重置为maxJumpImpulse
	if(parentNode.is_on_floor()):
		velocity.y += jumpImpulse
		jumpImpulse=jumpImpulse*impulseLoss
		if(jumpImpulse<minJumpImpulse):
			jumpImpulse=maxJumpImpulse
		
	velocity.y -= fallAcceleration * delta
	velocity=parentNode.move_and_slide(velocity, Vector3.UP)


