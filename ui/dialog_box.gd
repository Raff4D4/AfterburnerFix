extends CanvasLayer
class_name DialogBox

signal closed

@onready var _title: Label = $Root/Panel/Margin/VBox/TitleLabel
@onready var _body: Label = $Root/Panel/Margin/VBox/BodyLabel
@onready var _continue_button: Button = $Root/Panel/Margin/VBox/ContinueButton

var _open := false
var _armed := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_continue_button.pressed.connect(_on_continue_pressed)

func play(title: String, lines: Array[String]) -> void:
	if lines.is_empty():
		closed.emit()
		return
	_title.text = title
	_body.text = "\n".join(lines)
	visible = true
	_open = true
	_armed = false
	_wait_until_armed()
	get_tree().paused = true
	_continue_button.grab_focus()

func _wait_until_armed() -> void:
	await get_tree().create_timer(0.2, true).timeout
	_armed = true

func _unhandled_input(event: InputEvent) -> void:
	if not _open or not _armed:
		return
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"fire") or event.is_action_pressed(&"ui_select") or event.is_action_pressed(&"ui_cancel") or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		_close()

func _on_continue_pressed() -> void:
	_close()

func _close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	get_tree().paused = false
	closed.emit()
