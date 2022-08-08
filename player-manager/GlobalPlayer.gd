extends Node

const FIXEDNUM  = 1000.0
const FIXEDNUM2  = 10000.0#时间用这个
#每个动作对应一个type
var EMPTY_MOVE_MSG_JSON = {
	"type" : 0,  #0:null 1:move ,2:idle ,3:sit , 11: Flat01 ,12: Flat02, 13: Flat03 保持动作不变的标识999
	"delta" : 0.01667,
	"curPosition" : null,
	"curForward" : Vector3.ZERO,
	"nextForward" : Vector3.ZERO,
	"targetId": ""  # 用于动作目标对象
}

func _ready():
	pass # Replace with function body.

func vec3MultiTrans(vec3 : Vector3):
	return Vector3(
		int(vec3.x*FIXEDNUM),
		int(vec3.y*FIXEDNUM),
		int(vec3.z*FIXEDNUM))

func floatMultiTrans(n : float):
	return int(n*FIXEDNUM2)
	
func vec3DiviTrans(vec3 : Vector3):
	return Vector3(vec3.x/FIXEDNUM,vec3.y/FIXEDNUM,vec3.z/FIXEDNUM)

func intDiviTrans(n : int):
	return n / FIXEDNUM2

enum State {
	STOP=999, 
	MOVE=1, 
	IDLE=2, 
	SIT=3, 
	FLY=4,
	CREEP=10, 
	FLAT_01=11, 
	FLAT_02=12,
	FLAT_03=13,
	WALK=14, 
	JUMP=15,
	UPJUMP=16
}
enum Action {
	DISABLE=1000
	# 非混合动画
	LAUGH=1001, 
	CRY=1002, 
	CLAPPING_HAND=1003, 
	DANCING_RUN=1004,
	DANCE_A=1005,
	DJ_IDLE=1006,
	WAVE=1007,
	SPEAK=1008,
	SKATE_BOARD_SKILL_01=1009,
	# 混合动画
	VICTORY=2004,
	SEND_HEART=2006,
	SEND_BOMB=2007
}
	
enum Effect {
	# 特效动画
	DISABLE=3000,
	SEND_HEART=3001,
	RECEIVE_HEART=3002,
	SEND_BOMB=3003,
	RECEIVE_BOMB=3004
}

enum mixAnimationMode {
	# 混合动画过滤器模式
	TOP_FILTER, 
	BOTTOM_FILTER,
	NO_FILTER
}

const actionAnimationInfo = {
	Action.SEND_HEART: {
		"animation": "016_sendHeart",
		"effect": {
			"self": {
				"type": Effect.SEND_HEART
			}
		},
		"mode": mixAnimationMode.TOP_FILTER
	},
	Action.SEND_BOMB: {
		"animation": "018_Throw",
		"effect": {
			"self": {
				"type": Effect.SEND_BOMB
			}
		},
#		"mode": mixAnimationMode.NO_FILTER
	},
	Action.SKATE_BOARD_SKILL_01: {
		"animation": "Test_Skate_01",
		"move_animation": "Test_Skate_Move(Father) ",
		"relative": {
			"nextPosition": Vector3(0,0,-25),
			"curPosition": Vector3.ZERO,
			"curForward": Vector3(0,0,-1)
		}
	},
	Action.CRY: {
		"animation": "010_Cry"
	},
	Action.CLAPPING_HAND: {
		"animation": "009_Clapping"
	},
	Action.LAUGH: {
		"animation": "011_Laugh",
		"music": {
			"source": preload("res://player-manager/player/stateMachine/sounds/HipHopDancing.mp3"),
			"loop": true
		}
	},
	Action.DANCING_RUN: {
		"animation": "136_DancingRun"
	},
	Action.VICTORY: {
		"animation": "106_Walk_Victory01",
		"mode": mixAnimationMode.TOP_FILTER
	},
	Action.SPEAK: {
		"animation": "142_Speak"
	},
	Action.DANCE_A: {
		"animation": "133_DanceA"
	},
	Action.DJ_IDLE: {
		"animation": "137_DJIdle"
	},
	Action.WAVE: {
		"animation": "015_Wave"
	}
}
	
const effectAnimationInfo = {
	Effect.SEND_HEART: {
		"animation": "bullet_sendlove",
		"scene": "res://basicResources/effect/sendHeart/FX_Bullet_SendLove.tscn",
		"bone": "spine_002",
		"effect": {
			"target": {
				"type": Effect.RECEIVE_HEART
			}
		}
	},
	Effect.RECEIVE_HEART: {
		"animation": "hit_sendlove",
		"scene": "res://basicResources/effect/sendHeart/FX_Hit_SendLove.tscn",
		"bone": "spine_002"
	},
	Effect.SEND_BOMB: {
		"animation": "Bullet_bomb",
		"scene": "res://basicResources/effect/throw/FX_Bullet_bomb.tscn",
		
		"effect": {
			"target": {
				"type": Effect.RECEIVE_BOMB
			}
		}
	},
	Effect.RECEIVE_BOMB: {
		"animation": "Hit_bomb",
		"scene": "res://basicResources/effect/throw/FX_Hit_bomb.tscn",
		"bone": "spine_002"
	}
}
