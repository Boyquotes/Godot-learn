extends BasicAction

class_name VanlishAction



#消失动画持续时间 单位秒
var vanlishDuration =3
var ShaderAlphaUniformValuePath="/MeshInstance:material/0:shader_param/AlphaUniform"


var animationPlayerNode

func run(data):
	.run(data)
	InitVanlishAnimation()
	animationPlayerNode.play("Vanlish")



func InitVanlishAnimation():
	var animation =Animation.new()
	animation.set_length(vanlishDuration)
	animation.set_loop(false)
	
	animationPlayerNode = AnimationPlayer.new()
	animationPlayerNode.connect("animation_started",self,"VanlishStartCallback")
	animationPlayerNode.connect("animation_finished",self,"VanlishEndCallback")
	animationPlayerNode.add_animation("Vanlish",animation)
	parentNode.add_child(animationPlayerNode)

	var track_index = animation.add_track(Animation.TYPE_VALUE)
	print(str(parentNode.get_path())+ShaderAlphaUniformValuePath)
	animation.track_set_path(track_index, str(parentNode.get_path())+ShaderAlphaUniformValuePath)
	animation.track_insert_key(track_index, 0.0,1.0)

	animation.track_insert_key(track_index, vanlishDuration,0.0)
#

#在这个地方定义消失开始的回调（如果有）
func VanlishStartCallback(msg:String):
	print("VanlishStartCallback")
	pass

#在这个地方定义消失后的回调（如果有）
func VanlishEndCallback(msg:String):
	print("VanlishEndCallback")
	pass
