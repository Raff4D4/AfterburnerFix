extends PlayerBullet
class_name Missile

@export var smoke_color := Color(0.9, 0.7, 0.3, 0.8)

func _ready() -> void:
	if homing_turn_rate <= 0.0:
		homing_turn_rate = 5.0
	super._ready()
