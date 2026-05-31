# game_state_observer.gd  (autoload as GameStateObserver)
extends Node

signal boss_defeated(is_defeated: bool, stage: int)
signal player_defeated(stage: int)
signal stage_changed(new_stage: int)
signal item_unlocked(item: Items)
signal stage_transition_requested(new_stage_index: int)  # triggers fade + reset

func emit_boss_defeated(is_defeated: bool, stage: int) -> void:
	boss_defeated.emit(is_defeated, stage)

func emit_player_defeated(stage: int) -> void:
	player_defeated.emit(stage)

func emit_stage_changed(new_stage: int) -> void:
	stage_changed.emit(new_stage)

func emit_item_unlocked(item: Items) -> void:
	item_unlocked.emit(item)

func emit_stage_transition_requested(new_stage_index: int) -> void:
	stage_transition_requested.emit(new_stage_index)
