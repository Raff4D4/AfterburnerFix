extends AnimatedSprite2D
class_name Explosion

const FRAMES: Array[Texture2D] = [
	preload("res://assets/sprites/explosion_1.png"),
	preload("res://assets/sprites/explosion_2.png"),
	preload("res://assets/sprites/explosion_3.png"),
	preload("res://assets/sprites/explosion_4.png"),
	preload("res://assets/sprites/explosion_5.png"),
]

func _ready() -> void:
	var sf := SpriteFrames.new()
	sf.add_animation(&"default")
	sf.set_animation_speed(&"default", 16.0)
	sf.set_animation_loop(&"default", false)
	for tex in FRAMES:
		sf.add_frame(&"default", tex)
	sprite_frames = sf
	animation_finished.connect(_on_animation_finished)
	play(&"default")

func _on_animation_finished() -> void:
	queue_free()
