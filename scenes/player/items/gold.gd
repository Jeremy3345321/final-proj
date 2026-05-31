extends Pickups
class_name Gold

@export var gold : int = 5

func activate():
	player_reference.gain_gold(gold)
