extends Pickups
class_name Gem

@export var XP: float

func activate() -> void:
	super.activate()
	player_reference.gain_XP(XP)
