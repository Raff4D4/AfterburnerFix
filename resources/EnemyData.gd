extends Resource
class_name EnemyData

@export var max_health: int = 1
@export var move_pattern: StringName = &"straight"
@export var fire_pattern: StringName = &"none"
@export var fire_interval: float = 1.5
@export var bullet_scene: PackedScene
@export var score_value: int = 100
@export var drop_table: Array = []
@export var is_elite: bool = false
@export var elite_modulate: Color = Color(1.3, 0.45, 0.45)
@export var elite_scale: float = 1.2
