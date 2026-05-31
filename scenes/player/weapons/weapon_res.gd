extends Items
class_name Weapon

# Projectile properties
@export var damage: int
@export var speed: int
@export var cooldown: float
@export var upgrades: Array[Upgrade]
@export var item_needed: PassiveItem
@export var evolution: Weapon
@export var sound: AudioStream
@export var projectile_node: PackedScene = preload("res://scenes/player/weapons/projectile.tscn")
@export var battle_texture: Texture2D

var slot

func activate(_source, _target, _scene_tree) -> void:
	pass


func is_upgradable() -> bool:
	if level <= upgrades.size():
		return true
	return false


func upgrade_item():
	if not is_upgradable():
		return

	var upgrade = upgrades[level - 1]

	damage += upgrade.damage
	cooldown += upgrade.cooldown

	level += 1


func max_level_reached() -> bool:
	if upgrades.size() + 1 == level and upgrades.size() != 0:
		return true
	return false


func update(_delta) -> void:
	pass


func reset() -> void:
	pass
