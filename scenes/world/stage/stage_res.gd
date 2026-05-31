# stage_res.gd
extends Resource
class_name Stage

@export var stage_number: int = 1
@export var stage_name: String = "Stage 1"

## Enemies that can spawn during this stage
@export var enemy_pool: Array[Enemy] = []

## Items unlocked for the player's pool after completing this stage
@export var unlocked_weapons: Array[Weapon] = []
@export var unlocked_passives: Array[PassiveItem] = []

## Survival requirement in seconds before boss spawns (default 5 min = 300s)
@export var survival_seconds: int = 300

## Boss health multiplier relative to base
@export var boss_health_multiplier: float = 100.0
@export var boss_speed_multiplier: float = 2.5
