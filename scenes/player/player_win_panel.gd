extends NinePatchRect
@onready var main_menu: Button = $MainMenu

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameStateObserver.game_won.connect(_on_game_won)
	main_menu.pressed.connect(_on_main_menu_pressed)

func _on_game_won() -> void:
	get_tree().paused = true
	show()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_screen.tscn")
