extends Node
class_name WaveManager

const SPAWN_GROUPS: Array[StringName] = [&"spawn_top", &"spawn_left", &"spawn_right"]

var _waves: Array[WaveData] = []
var _current_wave := -1
var _enemies_spawned := 0
var _spawn_timer := 0.0
var _delay_timer := 0.0
var _waiting_for_clear := false
var _done := false
var _level_node: Node = null

func start(level: Node) -> void:
	_level_node = level
	var data := GameManager.level_data
	if data == null or data.waves.is_empty():
		push_warning("WaveManager: no waves in LevelData.")
		return
	_waves = data.waves
	_current_wave = -1
	_done = false
	_advance_wave()

func _process(delta: float) -> void:
	if _done or _waves.is_empty():
		return
	if _delay_timer > 0.0:
		_delay_timer -= delta
		return
	if _waiting_for_clear:
		if _living_enemy_count() == 0:
			_waiting_for_clear = false
			_advance_wave()
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_next_enemy()

func _advance_wave() -> void:
	_current_wave += 1
	if _current_wave >= _waves.size():
		_done = true
		_on_all_waves_done()
		return
	var wave := _waves[_current_wave]
	_enemies_spawned = 0
	_delay_timer = wave.delay_before
	_spawn_timer = 0.0
	EventBus.wave_started.emit(_current_wave, _waves.size())
	if wave.is_boss_arena:
		_signal_boss_arena()

func _spawn_next_enemy() -> void:
	var wave := _waves[_current_wave]
	if _enemies_spawned >= wave.count:
		_waiting_for_clear = true
		return
	var enemy := _create_enemy(wave)
	if enemy != null:
		_position_enemy(enemy, wave, _enemies_spawned, wave.count)
		var container := _entity_container()
		container.add_child(enemy)
	_enemies_spawned += 1
	_spawn_timer = wave.interval

func _create_enemy(wave: WaveData) -> Node:
	if wave.enemy_scene == null:
		push_warning("WaveManager: wave %d has no enemy_scene." % _current_wave)
		return null
	return wave.enemy_scene.instantiate()

func _get_camera_world_rect() -> Rect2:
	var view_size := Vector2(640, 360)
	var viewport := get_viewport()
	if viewport != null:
		view_size = viewport.get_visible_rect().size
	var center := view_size * 0.5
	var camera := viewport.get_camera_2d() if viewport != null else null
	if camera != null:
		if not is_zero_approx(camera.zoom.x) and not is_zero_approx(camera.zoom.y):
			view_size /= camera.zoom
		center = camera.get_screen_center_position()
	return Rect2(center - view_size * 0.5, view_size)

func _position_enemy(enemy: Node, wave: WaveData, index: int, total: int) -> void:
	if not (enemy is Node2D):
		return
	var rect := _get_camera_world_rect()
	var base_pos := Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - 40.0)
	var marker := _pick_spawn_marker(wave.spawn_group)
	if marker != null:
		base_pos = rect.position + marker.position
	var offset := _formation_offset(wave.formation, index, total)
	(enemy as Node2D).global_position = base_pos + offset

func _pick_spawn_marker(group: StringName) -> Node2D:
	var markers := get_tree().get_nodes_in_group(group)
	if markers.is_empty():
		return null
	return markers[randi() % markers.size()] as Node2D

func _formation_offset(formation: StringName, index: int, total: int) -> Vector2:
	var spacing := 36.0
	match formation:
		&"line":
			var half := float(total - 1) * 0.5
			return Vector2((float(index) - half) * spacing, 0.0)
		&"vee":
			var half := float(total - 1) * 0.5
			var x := (float(index) - half) * spacing
			var y := absf(float(index) - half) * spacing * 0.5
			return Vector2(x, y)
		_:
			return Vector2(randf_range(-100.0, 100.0), randf_range(-20.0, 20.0))

func _entity_container() -> Node:
	if _level_node != null:
		var entities := _level_node.get_node_or_null("Entities")
		if entities != null:
			return entities
	var container := get_tree().get_first_node_in_group(&"entities")
	return container if container != null else get_tree().current_scene

func _living_enemy_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group(&"enemies"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method(&"is_alive"):
			if node.is_alive():
				count += 1
		elif node is Node2D and node.visible:
			count += 1
	return count

func _signal_boss_arena() -> void:
	if _level_node != null and _level_node.has_method(&"enter_boss_arena"):
		_level_node.enter_boss_arena()

func _on_all_waves_done() -> void:
	var data := GameManager.level_data
	if data == null or data.boss_scene != null:
		return
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree():
		return
	if _living_enemy_count() > 0:
		_done = false
		_waiting_for_clear = true
		return
	EventBus.level_completed.emit(GameManager.current_level)
