#options.gd
extends VBoxContainer

@export var weapons: HBoxContainer
@export var passive_items: HBoxContainer
var option_slot_node = preload("res://scenes/player/option_slot.tscn")
@export var panel: NinePatchRect

func _ready() -> void:
	panel.hide()
	hide()

func close_option() -> void:
	panel.hide()
	hide()
	get_tree().paused = false


func add_option(item) -> int:
	if item.is_upgradable():
		var option_slot = option_slot_node.instantiate()
		option_slot.item = item
		add_child(option_slot)
		return 1
	return 0


func get_available_resource_in(items)-> Array[Items]:
	var resources : Array[Items] = []
	for item in items.get_children():
		if item.item != null:
			resources.append(item.item)
	return resources


func show_option() -> void:
	var weapons_available = get_available_resource_in(weapons)
	var passives_available = get_available_resource_in(passive_items)
	if weapons_available.size() == 0 and passives_available.size() == 0:
		return

	for slot in get_children():
		slot.queue_free()

	# Build full pool of valid options
	var pool: Array[Items] = []
	for weapon: Weapon in weapons_available:
		if weapon.is_upgradable():
			pool.append(weapon)
		if weapon.max_level_reached() and weapon.item_needed in passives_available:
			pool.append(weapon)
	for passive: PassiveItem in passives_available:
		if passive.is_upgradable():
			pool.append(passive)

	if pool.size() == 0:
		return

	# Pick up to 3 at random without repeats
	pool.shuffle()
	var selected = pool.slice(0, min(3, pool.size()))

	for item in selected:
		var option_slot = option_slot_node.instantiate()
		option_slot.item = item
		add_child(option_slot)

	show()
	panel.show()
	get_tree().paused = true


func get_available_upgrades()-> Array[Items]:
	var upgrades : Array[Items] = []
	for weapon : Weapon in get_available_resource_in(weapons):
		if weapon.is_upgradable():
			upgrades.append(weapon)
 
		if weapon.max_level_reached() and weapon.item_needed in get_available_resource_in(passive_items):
			upgrades.append(weapon)
 
	for passive_item : PassiveItem in get_available_resource_in(passive_items):
		if passive_item.is_upgradable():
			upgrades.append(passive_item)
 
	return upgrades
