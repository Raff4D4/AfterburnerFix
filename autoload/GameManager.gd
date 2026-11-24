extends Node

const STARTING_LIVES := 3
const STARTING_BOMBS := 1

var current_level: int = 0
var level_data: LevelData = null
var score: int = 0
var lives: int = STARTING_LIVES
var bombs: int = STARTING_BOMBS
var weapon: WeaponData = null
var is_run_active: bool = false

func start_run() -> void:
	current_level = 0
	level_data = null
	score = 0
	lives = STARTING_LIVES
	bombs = STARTING_BOMBS
	weapon = null
	is_run_active = true
	_announce_all()

func begin_level(index: int, data: LevelData) -> void:
	current_level = index
	level_data = data
	_announce_all()

func add_score(value: int) -> void:
	if value == 0:
		return
	score = maxi(score + value, 0)
	EventBus.score_changed.emit(score)

func add_life(amount: int = 1) -> void:
	if amount == 0:
		return
	lives = maxi(lives + amount, 0)
	EventBus.lives_changed.emit(lives)

func lose_life() -> bool:
	lives = maxi(lives - 1, 0)
	weapon = null
	EventBus.lives_changed.emit(lives)
	EventBus.weapon_changed.emit(weapon)
	if lives <= 0:
		is_run_active = false
		EventBus.player_died.emit()
		return false
	return true

func add_bomb(amount: int = 1) -> void:
	if amount == 0:
		return
	bombs = maxi(bombs + amount, 0)
	EventBus.bomb_changed.emit(bombs)

func use_bomb() -> bool:
	if bombs <= 0:
		return false
	bombs -= 1
	EventBus.bomb_changed.emit(bombs)
	return true

func set_weapon(data: WeaponData) -> void:
	weapon = data
	EventBus.weapon_changed.emit(weapon)

func end_run() -> void:
	is_run_active = false
	SaveManager.submit_score(score)

func _announce_all() -> void:
	EventBus.score_changed.emit(score)
	EventBus.lives_changed.emit(lives)
	EventBus.bomb_changed.emit(bombs)
	EventBus.weapon_changed.emit(weapon)
