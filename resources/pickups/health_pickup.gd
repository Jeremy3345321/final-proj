extends Pickups
class_name Health

@export var amount: int = 20

func activate() -> void:
	super.activate()
	player_reference.health += amount
