# world.gd
extends Node2D  # was Node, logs show it's Node2D

@onready var backgrounds: Array[Node] = [
	$World1,
	$World2,
	$World3,
]

@onready var player: CharacterBody2D = $Player
@onready var spawner: Node2D         = $Spawner
@onready var fade_rect: ColorRect    = $CanvasLayer/FadeRect

var current_stage_index: int = 0

func _ready() -> void:
	GameStateObserver.stage_transition_requested.connect(_on_stage_transition_requested)

	# CRITICAL: ignore mouse so FadeRect never blocks UI clicks underneath
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.show()
	_show_background(0)
	print("[world] ready done | fade_rect mouse_filter: ", fade_rect.mouse_filter)

func fade_in_only() -> void:
	print("[world] fade_in_only | paused: ", get_tree().paused)
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.8)

func _show_background(index: int) -> void:
	for i in backgrounds.size():
		backgrounds[i].visible = (i == index)

func _on_stage_transition_requested(new_stage_index: int) -> void:
	print("[world] transition received | index: ", new_stage_index, " | paused: ", get_tree().paused)
	await _do_transition(new_stage_index)

func _on_player_defeated(_stage: int) -> void:
	await _do_transition(current_stage_index)

func _do_transition(target_stage_index: int) -> void:
	get_tree().paused = false

	var tween_out = create_tween()
	tween_out.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.6)
	await tween_out.finished

	var tween_flash = create_tween()
	tween_flash.tween_property(fade_rect, "color", Color(1, 1, 1, 1), 0.15)
	tween_flash.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.15)
	await tween_flash.finished

	current_stage_index = target_stage_index
	_show_background(current_stage_index)
	player.reset_for_stage()
	spawner.set_stage(current_stage_index)
	print("[world] set_stage done")

	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.queue_free()
	print("[world] enemies cleared")
	for pickup in get_tree().get_nodes_in_group("Pickup"):
		pickup.queue_free()
	print("[world] pickups cleared")

	GameStateObserver.emit_stage_changed(current_stage_index + 1)
	print("[world] stage_changed emitted | paused: ", get_tree().paused)

	get_tree().paused = false
	var tween_in = create_tween()
	print("[world] tween_in created")
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.6)
	await tween_in.finished
	print("[world] fade-in done")
