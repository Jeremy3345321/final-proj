# enemy.gd
extends CharacterBody2D

@export var player_reference: CharacterBody2D
var damage_popup_node := preload("uid://cm86ws5ntx608")
var direction: Vector2
var speed: float = 75
var damage: int
var separation: float

var is_boss: bool = false  # Set by spawner when spawning the boss

var elite: bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://resources/shaders/rainbow_shader.tres")
			scale = Vector2(1.5, 1.5)

var health: float:
	set(value):
		health = value
		if health <= 0:
			drop_item()
			if is_boss:
				# Find which stage index the spawner is on
				var spawner = get_tree().current_scene.get_node_or_null("Spawner")
				var stage = spawner.current_stage_index + 1 if spawner else 1
				GameStateObserver.emit_boss_defeated(true, stage)

var type: Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		damage = value.damage
		health = value.health

var curr_player_pos: Vector2
var knockback: Vector2
var drop = preload("res://scenes/player/pickups/pickup.tscn")

func _ready() -> void:
	add_to_group("enemies")
	var group = randi() % WorldObserver.GROUP_COUNT
	WorldObserver.position_signals[group].connect(_on_curr_player_pos)

func _on_curr_player_pos(player_pos: Vector2) -> void:
	curr_player_pos = player_pos
	separation = (curr_player_pos - position).length()
	if separation >= 1300 and not elite:
		queue_free()
		return
	WorldObserver.report_enemy_proximity(self, separation)

func _physics_process(delta):
	check_seperation(delta)
	knockback_update(delta)

func check_seperation(_delta) -> void:
	separation = (curr_player_pos - position).length()
	if separation >= 1300 and not elite:
		queue_free()

func knockback_update(delta) -> void:
	velocity = (curr_player_pos - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 8)
	velocity += knockback
	var collider = move_and_collide(velocity * delta)
	if collider:
		collider.get_collider().knockback = (collider.get_collider().global_position - global_position).normalized() * 50

func damage_popup(amount) -> void:
	var popup := damage_popup_node.instantiate()
	popup.text = str(amount)
	popup.position = position + Vector2(-50, -25)
	get_tree().current_scene.add_child(popup)

func take_damage(amount) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
	tween.bind_node(self)
	damage_popup(amount)
	health -= amount

func drop_item() -> void:
	if type.drops.size() == 0:
		queue_free()
		return

	var item = type.drops.pick_random()
	if elite:
		item = preload("res://resources/pickups/chest.tres")

	var item_to_drop = drop.instantiate()
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
	queue_free()
