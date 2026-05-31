extends NinePatchRect
@onready var retry: Button = %Retry
@onready var main_menu: Button = %MainMenu

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameStateObserver.player_defeated.connect(_on_player_defeated)
	retry.pressed.connect(_on_retry_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)

func _on_player_defeated(_stage: int) -> void:
	get_tree().paused = true
	show()

func _on_retry_pressed() -> void:
	hide()
	get_tree().paused = false
	var spawner = get_tree().current_scene.get_node_or_null("Spawner")
	var current_index = spawner.current_stage_index if spawner else 0
	GameStateObserver.emit_stage_transition_requested(current_index)

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_screen.tscn") 
