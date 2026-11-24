extends Area2D
class_name EnemyBullet

const DESPAWN_MARGIN := 32.0
const GROUP: StringName = &"enemy_bullets"

@export var speed := 130.0
@export var damage := 1
@export var direction := Vector2.DOWN
@export var tint := Color(1.0, 0.6, 0.45)
@export var bullet_scale := 1.0

var _velocity := Vector2.ZERO

func _ready() -> void:
	add_to_group(GROUP)
	modulate = tint
	scale = Vector2.ONE * bullet_scale
	_apply_direction()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func configure(
	p_speed: float,
	p_damage: int,
	p_direction: Vector2,
	p_tint := Color(1.0, 0.6, 0.45),
	p_scale := 1.0
) -> void:
	speed = p_speed
	damage = p_damage
	direction = p_direction
	tint = p_tint
	bullet_scale = p_scale

func _physics_process(delta: float) -> void:
	position += _velocity * delta
	if _is_outside_view():
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(&"player"):
		_hit(area)
	elif area.name == "Hurtbox":
		var parent_node := area.get_parent()
		if parent_node != null:
			_hit(parent_node)

func _hit(target: Node) -> void:
	if target == null:
		return
	if target.has_method(&"take_damage"):
		target.take_damage(damage)
	call_deferred(&"queue_free")

func _apply_direction() -> void:
	_velocity = direction.normalized() * speed
	rotation = _velocity.angle() - PI * 0.5

func _is_outside_view() -> bool:
	var view_size := get_viewport_rect().size
	var center := view_size * 0.5
	var camera := get_viewport().get_camera_2d()
	if camera != null:
		if not is_zero_approx(camera.zoom.x) and not is_zero_approx(camera.zoom.y):
			view_size /= camera.zoom
		center = camera.get_screen_center_position()
	var limit := view_size * 0.5 + Vector2(DESPAWN_MARGIN, DESPAWN_MARGIN)
	var offset := global_position - center
	return absf(offset.x) > limit.x or absf(offset.y) > limit.y
