extends Pickups
class_name PickupMagnet


func activate() -> void:
	super.activate()
	player_reference.get_tree().call_group("Pickups", "follow", player_reference, true)
