extends Resource
class_name Pickups

@export var title: String
@export var icon: Texture2D
@export var custom_scale: Vector2
@export_multiline var description: String
@export var sound: AudioStream

var player_reference: CharacterBody2D


func activate() -> void:
	SoundManager.play_sfx(sound)
