extends Node
class_name ComboTracker

const MAX_MULTIPLIER := 5
const COMBO_WINDOW := 2.0

var multiplier: int = 1
var _timer := 0.0

func _ready() -> void:
	add_to_group(&"combo_tracker")

func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer -= delta
	if _timer <= 0.0:
		_reset()

func register_kill(base_score: int) -> void:
	_timer = COMBO_WINDOW
	var points := base_score * multiplier
	GameManager.add_score(points)
	if multiplier < MAX_MULTIPLIER:
		multiplier += 1
		EventBus.combo_changed.emit(multiplier)

func _reset() -> void:
	if multiplier == 1:
		return
	multiplier = 1
	EventBus.combo_changed.emit(multiplier)
