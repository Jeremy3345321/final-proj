extends Resource
class_name Enemy

enum AttackType {
	MELEE,
	RANGED
}

@export var title: String
@export var texture: Texture2D
@export var health: int
@export var damage: int
@export var attack_type: AttackType
@export var drops: Array[Pickups]
