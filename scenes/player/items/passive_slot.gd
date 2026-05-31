extends PanelContainer


@export var player: CharacterBody2D
@export var item: PassiveItem:
	set(value):
		item = value
		if item == null:
			$TextureRect.texture = null
			return
		$TextureRect.texture = value.texture
		if player:
			item.player_reference = player  # ✅ Set immediately when item is assigned

func _ready() -> void:
	if item != null and player != null:
		item.player_reference = player
