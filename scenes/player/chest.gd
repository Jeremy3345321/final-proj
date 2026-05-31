# chest.gd  (updated — only the changed parts shown; rest is identical)
extends NinePatchRect

@onready var chest = $AnimatedSprite2D
@onready var rewards = $Rewards
@onready var options = %Options

@export var sound: AudioStream
@export var available_weapons: Array[Weapon]
@export var available_passives: Array[PassiveItem]

const NEW_ITEM_CHANCE: float = 0.10
const PITY_THRESHOLD: int = 5
var no_new_item_streak: int = 0
var evolved_base_weapons: Array[Weapon] = []

func _ready():
	randomize()
	hide()
	$Open.show()
	$Close.hide()
	GameStateObserver.item_unlocked.connect(_on_item_unlocked)

## Adds newly unlocked items to this chest's available pools.
func _on_item_unlocked(item: Items) -> void:
	if item is Weapon and item not in available_weapons:
		available_weapons.append(item)
		print("[chest] Added to weapon pool: ", item.title)
	elif item is PassiveItem and item not in available_passives:
		available_passives.append(item)
		print("[chest] Added to passive pool: ", item.title)

# ── Everything below is unchanged from your original chest.gd ───────────────

func open():
	clear_reward()
	chest.play("idle")
	get_tree().paused = true
	show()
	$Open.show()
	$Close.hide()

func set_reward():
	clear_reward()

	var unowned = get_unowned_items()
	var new_item: Items = null
	if unowned.size() > 0 and (randf() < NEW_ITEM_CHANCE or no_new_item_streak >= PITY_THRESHOLD):
		new_item = unowned.pick_random()
		grant_new_item(new_item)
		no_new_item_streak = 0
		print("[chest.gd] New item granted: ", new_item.title, " | streak reset")
	else:
		no_new_item_streak += 1
		print("[chest.gd] No new item | streak: ", no_new_item_streak)

	var chance = randf()
	var slot_start: int
	var slot_end: int
	if chance < 0.5:
		slot_start = 2; slot_end = 3
		print("[chest.gd] rare")
	elif chance < 0.75:
		slot_start = 1; slot_end = 4
		print("[chest.gd] epic")
	else:
		slot_start = 0; slot_end = 5
		print("[chest.gd] legendary")

	var new_item_placed = false
	for index in range(slot_start, slot_end):
		if new_item and not new_item_placed:
			rewards.get_child(index).texture = new_item.texture
			new_item_placed = true
		else:
			var upgrades = options.get_available_upgrades()
			if upgrades.size() == 0:
				add_gold(index)
			else:
				var selected_upgrade: Items = upgrades.pick_random()
				if selected_upgrade is Weapon and selected_upgrade.max_level_reached():
					rewards.get_child(index).texture = selected_upgrade.evolution.texture
				else:
					rewards.get_child(index).texture = selected_upgrade.texture
				selected_upgrade.upgrade_item()

func get_unowned_items() -> Array[Items]:
	var owned: Array = []
	owned.append_array(options.get_available_resource_in(options.weapons))
	owned.append_array(options.get_available_resource_in(options.passive_items))

	evolved_base_weapons.clear()
	for weapon in available_weapons:
		if weapon.evolution != null and weapon.evolution in owned:
			evolved_base_weapons.append(weapon)

	var unowned: Array[Items] = []
	for weapon in available_weapons:
		if weapon not in owned and weapon not in evolved_base_weapons:
			unowned.append(weapon)
	for passive in available_passives:
		if passive not in owned:
			unowned.append(passive)
	return unowned

func grant_new_item(item: Items) -> void:
	if item is Weapon:
		for slot in options.weapons.get_children():
			if slot.item == null:
				slot.item = item
				return
	elif item is PassiveItem:
		for slot in options.passive_items.get_children():
			if slot.item == null:
				slot.item = item
				return

func upgrade_item(start, end):
	for index in range(start, end):
		if index >= rewards.get_child_count():
			break
		var upgrades = options.get_available_upgrades()
		if upgrades.size() == 0:
			add_gold(index)
		else:
			var selected_upgrade: Items = upgrades.pick_random()
			if selected_upgrade is Weapon and selected_upgrade.max_level_reached():
				rewards.get_child(index).texture = selected_upgrade.evolution.texture
			else:
				rewards.get_child(index).texture = selected_upgrade.texture
			selected_upgrade.upgrade_item()

func clear_reward():
	for slot in rewards.get_children():
		slot.texture = null

func _on_close_pressed():
	get_tree().paused = false
	hide()

func _on_open_pressed():
	print("[chest.gd] Open pressed")
	clear_reward()
	chest.play("open_chest")
	await chest.animation_finished
	SoundManager.play_sfx(sound)
	set_reward()
	$Open.hide()
	$Close.show()

func add_gold(index):
	var gold: Gold = load("res://resources/pickups/gold.tres")
	gold.player_reference = owner
	rewards.get_child(index).texture = gold.icon
	gold.activate()
