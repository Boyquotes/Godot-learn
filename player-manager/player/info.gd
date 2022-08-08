extends Node
class_name Info

var _userId = 0
var _userName = ""
var _isSelfPlayer = false

var _isAbleRun = false
var _isAbleMove = true
var _isAbleWalk = false
var _isAbleIdle = false
var _isAbleJump = false
var _isAbleSit = false
var _isAbleLie = false

var _isAbleCollison = false # 能否发碰撞信号
var _isAbleCollidePlayer = true

var _isRunningAni = false
var _isRobotAccount = "2";  # 用户是否为npc 1是 2否
var _forceStop = true

export var _max_speed: = 12.0
export var _move_speed: = 10.0
export var _creep_move_speed: = 20.0 # 爬行速度
export var _basic_move_speed: = 10.0
export var _gravity = -100.0
export var _jump_impulse = 25
export var _rotation_speed_factor: = 10.0
export var _friction = 5



