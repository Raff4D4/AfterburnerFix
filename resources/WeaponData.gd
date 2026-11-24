extends Resource
class_name WeaponData

@export var display_name: String = "Default Cannon"
@export var bullet_scene: PackedScene
@export var fire_rate: float = 8.0
@export var damage: int = 1
@export_range(1, 12, 1) var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var is_homing: bool = false
