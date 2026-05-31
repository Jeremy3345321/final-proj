extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 200
var damage: int = 1
var knockback: int = 90
var source
@onready var particle_effect: GPUParticles2D = %GPUParticles2D
@onready var sprite_2d: Sprite2D = %Sprite2D
var particle_material: ParticleProcessMaterial
var projectile_texture: Texture2D

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _ready() -> void:
	if particle_material:
		particle_effect.process_material = particle_material
		particle_effect.emitting = true
	
	if projectile_texture:
		sprite_2d.texture = projectile_texture
	



func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if "might" in source:
			body.take_damage(damage * source.might)
		else:
			body.take_damage(damage)

		body.knockback = direction * knockback

func _on_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
