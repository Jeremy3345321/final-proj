# boss_defeat_panel.gd
extends NinePatchRect

@onready var title_label: Label    = %Title
@onready var subtitle_label: Label = %Subtitle
@onready var next_button: Button   = %NextStage
@onready var stay_button: Button   = %StayButton

var _defeated_stage: int = 0

func _ready() -> void:
	hide()
	# Must process while paused so buttons work when tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameStateObserver.boss_defeated.connect(_on_boss_defeated)
	next_button.pressed.connect(_on_next_stage_pressed)
	stay_button.pressed.connect(_on_stay_button_pressed)

func _on_boss_defeated(is_defeated: bool, stage: int) -> void:
	if not is_defeated:
		return
	_show_panel(stage)

func _show_panel(defeated_stage: int) -> void:
	_defeated_stage = defeated_stage
	get_tree().paused = true

	var next_stage = defeated_stage + 1
	var is_final   = next_stage > 3
	title_label.text = "Stage %d Complete!" % defeated_stage

	# Auto-find spawner — no Inspector assignment needed
	var spawner = get_tree().current_scene.get_node_or_null("Spawner")
	var lines: Array[String] = []
	if spawner and spawner.current_stage_index < spawner.stages.size():
		var stage_res: Stage = spawner.stages[spawner.current_stage_index]
		for w in stage_res.unlocked_weapons:
			lines.append("⚔ " + w.title)
		for p in stage_res.unlocked_passives:
			lines.append("✦ " + p.title)

	subtitle_label.text = "Unlocked:\n" + "\n".join(lines) if lines.size() > 0 else ""

	if is_final:
		next_button.text = "You Win!"
		stay_button.hide()
	else:
		next_button.text = "Next"
		stay_button.show()

	show()

func _on_next_stage_pressed() -> void:
	print("[boss_panel] next pressed")
	hide()
	get_tree().paused = false
	GameStateObserver.emit_stage_transition_requested(_defeated_stage)

func _on_stay_button_pressed() -> void:
	print("[boss_panel] stay pressed")
	hide()
	get_tree().paused = false
