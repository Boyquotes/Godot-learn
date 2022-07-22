
extends TextureButton

const SCALE = 1.2
const DURATION = 0.2

onready var _initial_scale = get_scale()
var _scale_tween = null


func _ready():
	self.connect("mouse_enter", self, "_on_mouse_enter")
	self.connect("mouse_exit", self, "_on_mouse_exit")
	_scale_tween = Tween.new()
	add_child(_scale_tween)


func _on_mouse_enter():
	_scale_tween.interpolate_property(get_parent(), "transform/scale", \
		get_parent().get_scale(), _initial_scale*SCALE, DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	_scale_tween.start()


func _on_mouse_exit():
	_scale_tween.interpolate_property(get_parent(), "transform/scale", \
		get_parent().get_scale(), _initial_scale, DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	_scale_tween.start()


