extends Resource
class_name WaveData

@export var enemy_scene: PackedScene
@export_range(0, 100, 1) var count: int = 1
@export var spawn_group: StringName = &"spawn_top"
@export var interval: float = 0.5
@export var delay_before: float = 1.0
@export var formation: StringName = &"line"
@export var is_boss_arena: bool = false
