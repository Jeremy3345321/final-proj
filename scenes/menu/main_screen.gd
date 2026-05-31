# main_screen.gd
extends Control

# Stages are already assigned in the Spawner Inspector — no need to pass them here.

@onready var world: Node = get_parent().get_parent()

func _ready() -> void:
	show()

func _on_start_pressed() -> void:
	world.get_node("Spawner").set_stage(0)
	hide()
	world.fade_in_only()
