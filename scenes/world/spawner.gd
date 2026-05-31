# spawner.gd
extends Node2D

@export var player: CharacterBody2D
@export var enemy: PackedScene
@export var destructible: PackedScene

## Assign your 3 Stage resources here in the Inspector
@export var stages: Array[Stage] = []

@onready var elite_timer: Timer = $Elite

var distance: float = 1000
var can_spawn: bool = true
var boss_spawned: bool = false
var spawn_surge_active: bool = false
var current_stage_index: int = 0

var current_stage: Stage:
	get:
		if stages.size() == 0:
			return null
		return stages[min(current_stage_index, stages.size() - 1)]

var minute: int:
	set(value):
		minute = value
		%Minute.text = str(value)
		var total_seconds = minute * 60 + second
		if current_stage and total_seconds >= current_stage.survival_seconds and not boss_spawned:
			spawn_boss()
			elite_timer.wait_time = max(5.0, elite_timer.wait_time * 0.4)

var second: int:
	set(value):
		second = value
		if second >= 60:
			second -= 60
			minute += 1
		%Second.text = str(second).lpad(2, '0')
		var total_seconds = minute * 60 + second
		if total_seconds >= 150 and not spawn_surge_active:
			spawn_surge_active = true
			print("[spawner] Spawn surge at 2:30")

func _ready() -> void:
	GameStateObserver.boss_defeated.connect(_on_boss_defeated)

func _physics_process(_delta: float) -> void:
	can_spawn = get_tree().get_node_count_in_group("Enemy") < 700

# ── Called by World after the fade, instead of self-managing ─────────────────

func set_stage(index: int) -> void:
	current_stage_index = index
	minute = 0
	second = 0
	boss_spawned = false
	spawn_surge_active = false
	print("[spawner] Stage set → ", current_stage_index + 1,
		  " (", current_stage.stage_name if current_stage else "?", ")")

# ── Boss defeat: unlock items, let BossDefeatPanel handle the panel ───────────

func _on_boss_defeated(is_defeated: bool, _stage: int) -> void:
	if not is_defeated:
		return
	_unlock_stage_items()

func _unlock_stage_items() -> void:
	if current_stage == null:
		return
	for weapon in current_stage.unlocked_weapons:
		print("[spawner] Unlocked weapon: ", weapon.title)
		GameStateObserver.item_unlocked.emit(weapon)
	for passive in current_stage.unlocked_passives:
		print("[spawner] Unlocked passive: ", passive.title)
		GameStateObserver.item_unlocked.emit(passive)

## Called by BossDefeatPanel when player clicks "Advance".
## Tells World to handle the full transition (fade + reset + background swap).
func advance_to_next_stage() -> void:
	var next_index = current_stage_index + 1
	if next_index >= stages.size():
		print("[spawner] All stages complete!")
		# TODO: trigger win screen
		return
	GameStateObserver.emit_stage_transition_requested(next_index)

# ── Spawning ──────────────────────────────────────────────────────────────────

func spawn(pos: Vector2, is_elite: bool = false) -> void:
	if not can_spawn and not is_elite:
		return
	if current_stage == null or current_stage.enemy_pool.size() == 0:
		return

	var enemy_instance = enemy.instantiate()
	enemy_instance.player_reference = player
	enemy_instance.type = current_stage.enemy_pool[min(minute, current_stage.enemy_pool.size() - 1)]
	enemy_instance.position = pos
	enemy_instance.curr_player_pos = player.global_position

	var hp_multiplier: float = 1.0 + (minute * 0.15)
	enemy_instance.health *= hp_multiplier
	enemy_instance.elite = is_elite
	if is_elite:
		enemy_instance.health *= 3.5
		enemy_instance.speed *= 1.25

	get_tree().current_scene.add_child(enemy_instance)

func spawn_boss() -> void:
	if current_stage == null or current_stage.enemy_pool.size() == 0:
		return
	boss_spawned = true
	var boss = enemy.instantiate()
	boss.player_reference = player
	boss.type = current_stage.enemy_pool[current_stage.enemy_pool.size() - 1]
	boss.position = get_random_pos()
	boss.curr_player_pos = player.global_position
	boss.elite = true
	boss.is_boss = true
	boss.scale = Vector2(4, 4)
	boss.health *= current_stage.boss_health_multiplier
	boss.speed *= current_stage.boss_speed_multiplier
	get_tree().current_scene.add_child(boss)
	print("[spawner] Boss spawned for stage ", current_stage_index + 1)

func get_random_pos() -> Vector2:
	return player.global_position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

func amount(number: int = 1) -> void:
	for i in range(number):
		spawn(get_random_pos())

func get_spawn_amount() -> int:
	var total_seconds = minute * 60 + second
	var base = 4 + (total_seconds / 30)
	return base * 4 if spawn_surge_active else base

func _on_timer_timeout() -> void:
	second += 1
	amount(get_spawn_amount())

func _on_pattern_timeout() -> void:
	for i in range(60):
		spawn(get_random_pos())

func _on_elite_timeout() -> void:
	spawn(get_random_pos(), true)

func _on_destructible_timeout() -> void:
	spawn_destructible(get_random_pos())

func spawn_destructible(pos: Vector2) -> void:
	var object_instance = destructible.instantiate()
	object_instance.position = pos
	get_tree().current_scene.add_child(object_instance)
