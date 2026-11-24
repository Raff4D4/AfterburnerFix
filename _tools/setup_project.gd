@tool
extends SceneTree

const AUTOLOADS := {
	"EventBus": "res://autoload/EventBus.gd",
	"SaveManager": "res://autoload/SaveManager.gd",
	"GameManager": "res://autoload/GameManager.gd",
	"AudioManager": "res://autoload/AudioManager.gd",
	"SceneRouter": "res://autoload/SceneRouter.gd",
}


func _initialize() -> void:
	for alias in AUTOLOADS:
		ProjectSettings.set_setting("autoload/" + alias, "*" + AUTOLOADS[alias])

	ProjectSettings.set_setting("audio/buses/default_bus_layout", "res://default_bus_layout.tres")
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "expand")
	ProjectSettings.set_setting("display/window/size/viewport_width", 640)
	ProjectSettings.set_setting("display/window/size/viewport_height", 360)
	ProjectSettings.set_setting("display/window/size/window_width_override", 1280)
	ProjectSettings.set_setting("display/window/size/window_height_override", 720)

	_add_action(&"move_up", [KEY_W, KEY_UP])
	_add_action(&"move_down", [KEY_S, KEY_DOWN])
	_add_action(&"move_left", [KEY_A, KEY_LEFT])
	_add_action(&"move_right", [KEY_D, KEY_RIGHT])
	_add_action(&"fire", [KEY_SPACE, KEY_J, KEY_Z])
	_add_action(&"barrel_roll", [KEY_SHIFT, KEY_K, KEY_X])

	var err := ProjectSettings.save()
	print("setup_project: save -> ", error_string(err))
	quit()


func _add_action(action: StringName, keys: Array) -> void:
	var events: Array[InputEvent] = []
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		events.append(ev)
	ProjectSettings.set_setting("input/" + String(action), {
		"deadzone": 0.2,
		"events": events,
	})
