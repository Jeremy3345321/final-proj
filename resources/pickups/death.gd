extends Pickups
class_name Death


func activate() -> void:
	super.activate()
	player_reference.get_tree().call_group("Enemy", "drop_item")
