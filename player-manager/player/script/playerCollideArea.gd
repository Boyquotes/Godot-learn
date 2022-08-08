extends Area

func _ready():
	self.connect("body_entered", self, "_on_player_enter")

func _on_player_enter(body:Node):
	if "player" in body.name and get_node("../Info")._isAbleCollison:
		print("========================================player in collision")
		get_node("..").emit_signal("player_collison", body)
			
	pass 
