# player.gd
extends CharacterBody2D

@onready var onboard: Label = %Onboard
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var boss_defeat_panel: NinePatchRect = %BossDefeatPanel
@onready var player_defeat_panel: NinePatchRect = %PlayerDefeatPanel

## The weapon the player always starts with — kept on stage reset
@export var starting_weapon: Weapon
@export var starting_passive: PassiveItem  # optional; set if player starts with a passive too

var movement_speed: float = 150
var _is_defeated: bool = false

var health: float = 100:
	set(value):
		health = max(value, 0)
		%Health.value = value
		if health <= 0 and not _is_defeated:
			_is_defeated = true
			GameStateObserver.emit_player_defeated(0)
var max_health: float = 100:
	set(value):
		max_health = value
		%Health.max_value = value
var recovery: float = 0
var armor: float = 0
var might: float = 1.0
var area: float = 0
var magnet: float = 0:
	set(value):
		magnet = value
		%MagnetArea.shape.radius = 50 + value
var growth: float = 1
var nearest_enemy
var nearest_enemy_distance: float = 350 + area
var XP: int = 0:
	set(value):
		XP = value
		%XP.value = value
var total_xp: int = 0
var level: int = 1:
	set(value):
		level = value
		%XPLabel.text = "Lv " + str(value)
		%XP.max_value = xp_for_level(value)
		%Options.show_option()
var gold: int = 0:
	set(value):
		gold = value
		%Gold.text = "G: " + str(value)

func _physics_process(delta: float) -> void:
	_update_nearest_enemy()
	var input := Input.get_vector("left", "right", "up", "down")
	velocity = input * movement_speed
	move_and_collide(velocity * delta)
	check_XP()
	health += recovery * delta
	_update_animation(input)

func _update_animation(input: Vector2) -> void:
	var anim := "run" if input != Vector2.ZERO else "idle"
	if animation_player.current_animation != anim:
		animation_player.play(anim)
	if input.x != 0:
		$Sprite2D.flip_h = input.x < 0

func _update_nearest_enemy() -> void:
	nearest_enemy = null
	nearest_enemy_distance = 350 + area
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var dist: float = position.distance_to(enemy.position)
		if dist < nearest_enemy_distance:
			nearest_enemy_distance = dist
			nearest_enemy = enemy

func _ready() -> void:
	$PositionBroadcast0.start()
	$PositionBroadcast1.start($PositionBroadcast1.wait_time / 3.0)
	$PositionBroadcast2.start($PositionBroadcast2.wait_time / 3.0 * 2.0)
	_fade_out_onboard()
	$Sprite2D.scale = Vector2(2, 2)
	$Sprite2D.z_index += 1

func _on_position_broadcast_0_timeout() -> void:
	WorldObserver.emit_player_pos(0, position)
func _on_position_broadcast_1_timeout() -> void:
	WorldObserver.emit_player_pos(1, position)
func _on_position_broadcast_2_timeout() -> void:
	WorldObserver.emit_player_pos(2, position)

func take_damage(amount: int) -> void:
	health -= max(amount - armor, 0)

func _on_self_damage_body_entered(body) -> void:
	take_damage(body.damage)

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)

func gain_XP(amount) -> void:
	XP += amount * growth
	total_xp += amount * growth

func check_XP() -> void:
	if XP > %XP.max_value:
		XP -= %XP.max_value
		level += 1

func _fade_out_onboard() -> void:
	%Onboard.show()
	await get_tree().create_timer(5.0).timeout
	var tween = create_tween()
	tween.tween_property(onboard, "modulate:a", 0.0, 1.5)
	tween.tween_callback(onboard.hide)

func _on_magnet_area_entered(body_area: Area2D) -> void:
	if body_area.has_method("follow"):
		body_area.follow(self)

func xp_for_level(lvl: int) -> int:
	return int(10 * pow(1.4, lvl - 1))

func gain_gold(amount) -> void:
	gold += amount

func open_chest() -> void:
	$UI/Chest.open()

# ── Stage Reset ──────────────────────────────────────────────────────────────

## Called by the World node after the fade-out completes.
## Resets all stats and items, then restores the starting item.
func reset_for_stage() -> void:
	_is_defeated = false
	
	# Reset base stats
	movement_speed = 150
	max_health = 100
	health = 100
	recovery = 0
	armor = 0
	might = 1.0
	area = 0
	magnet = 0
	growth = 1
	XP = 0
	total_xp = 0
	level = 1
	position = Vector2.ZERO

	# Clear all weapon and passive slots
	for slot in %Options.weapons.get_children():
		slot.item = null
	for slot in %Options.passive_items.get_children():
		slot.item = null

	# Restore starting weapon
	if starting_weapon != null:
		# Reset the resource back to level 1 before granting
		starting_weapon.level = 1
		for slot in %Options.weapons.get_children():
			if slot.item == null:
				slot.item = starting_weapon
				break

	# Restore starting passive (optional)
	if starting_passive != null:
		starting_passive.level = 1
		for slot in %Options.passive_items.get_children():
			if slot.item == null:
				slot.item = starting_passive
				break

	print("[player] Reset for new stage. Starting weapon: ",
		  starting_weapon.title if starting_weapon else "none")
