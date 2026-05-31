extends Sprite2D

var frame_counter = 0
var health : float = 5:
	set(value):
		health = value
		if health < 0:
			drop_item()
var separation : float
@onready var player_reference = get_tree().current_scene.find_child("Player")

var drop_node = preload("res://scenes/player/pickups/pickup.tscn")
@export var drops : Array[Pickups]


func _physics_process(_delta):
	frame_counter += 1
	if frame_counter >= 6:
		frame_counter = 0
		frame = (frame + 1) % 8
	
	separation = (player_reference.position - position).length()
	if separation < player_reference.nearest_enemy_distance:
		player_reference.nearest_enemy = self
	

func take_damage(amount = 1):
	health -= amount
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	tween.bind_node(self)


func drop_item():
	var item = drops.pick_random()
	
	var item_to_drop = drop_node.instantiate()
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
	queue_free()
