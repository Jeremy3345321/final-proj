extends Node
signal curr_player_pos_0(position: Vector2)
signal curr_player_pos_1(position: Vector2)
signal curr_player_pos_2(position: Vector2)
signal nearest_enemy_changed(enemy: CharacterBody2D)

const GROUP_COUNT = 3
var position_signals: Array
var _nearest_enemy: CharacterBody2D = null
var _nearest_distance: float = INF

func _ready() -> void:
	position_signals = [curr_player_pos_0, curr_player_pos_1, curr_player_pos_2]

func emit_player_pos(group: int, pos: Vector2) -> void:
	position_signals[group].emit(pos)

func reset_nearest() -> void:
	_nearest_enemy = null
	_nearest_distance = INF

func report_enemy_proximity(enemy: CharacterBody2D, distance: float) -> void:
	if distance < _nearest_distance:
		_nearest_distance = distance
		_nearest_enemy = enemy
		nearest_enemy_changed.emit(enemy)
