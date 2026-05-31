extends Weapon
class_name Circular

@export var angular_speed = 20
@export var radius = 20
@export var amount = 1
@export var custom_scale: Vector2
@export var particle_effect: ParticleProcessMaterial
var projectile_reference : Array[Area2D]
var angle : float

func activate(source, _target, _scene_tree):
	reset()
	
	for i in range(amount):
		add_to_player(source)

func update(delta):
	angle += angular_speed * delta
	for i in range(projectile_reference.size()):
		var offset = i * (360.0/amount)
		projectile_reference[i].position = radius * Vector2(cos(deg_to_rad(angle + offset)), sin(deg_to_rad(angle + offset)))
		projectile_reference[i].show()
	
func add_to_player(source):
	var projectile = projectile_node.instantiate()
	projectile.speed = 0
	projectile.damage = damage
	projectile.source = source
	projectile.find_child("Sprite2D").texture = battle_texture
	projectile.find_child("Sprite2D").scale = custom_scale
	projectile.particle_material = particle_effect
	projectile.hide()
	projectile_reference.append(projectile)
	source.call_deferred("add_child",projectile)

func upgrade_item():
	if max_level_reached():
		slot.item = evolution
		return
	
	if not is_upgradable():
		return
	
	var upgrade = upgrades[level - 1]
	
	angular_speed += upgrade.angular_speed
	amount += upgrade.amount
	damage += upgrade.damage
	
	level += 1

func reset():
	for i in range(projectile_reference.size()):
		projectile_reference.pop_front().queue_free()
