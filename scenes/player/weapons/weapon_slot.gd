# item_slot.gd
extends PanelContainer
@export var item: Weapon: set = _on_item_set
@export var player: CharacterBody2D 

@warning_ignore("shadowed_variable")
func _ready() -> void:
	assert(player != null, "WeaponSlot: player reference not set!")

func _on_item_set(value: Weapon) -> void:
	if item != null and item.has_method("reset"):
		item.reset()

	item = value
	if item == null:
		$TextureRect.texture = null
		$Cooldown.stop()
		return

	$TextureRect.texture = item.texture
	$Cooldown.wait_time = item.cooldown
	item.slot = self
	$Cooldown.start()


func _physics_process(delta: float) -> void:
	if item != null and item.has_method("update"):
		item.update(delta)


func _on_cooldown_timeout() -> void:
	if item and player:
		if item.cooldown <= 0.0:
			item.cooldown = 0.1
		$Cooldown.wait_time = item.cooldown
		item.activate(player, player.nearest_enemy, get_tree())
