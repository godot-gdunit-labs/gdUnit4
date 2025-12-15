@abstract class_name GdUnitBaseCommand
extends RefCounted


var id: String
var icon: Texture2D
var shortcut: Shortcut = null
var shortcut_type: GdUnitShortcut.ShortCut


func _init(p_id: String, p_shortcut: GdUnitShortcut.ShortCut = GdUnitShortcut.ShortCut.NONE) -> void:
	id = p_id
	shortcut_type = p_shortcut
	_set_shortcut()


func update_shortcut() -> void:
	_set_shortcut()


func _set_shortcut() -> void:
	if shortcut_type == GdUnitShortcut.ShortCut.NONE:
		return

	var property_name := GdUnitShortcut.as_property(shortcut_type)
	var property := GdUnitSettings.get_property(property_name)
	var keys := GdUnitShortcut.default_keys(shortcut_type)
	if property != null:
		keys = property.value()
	var inputEvent := _create_shortcut_input_even(keys)

	shortcut = Shortcut.new()
	shortcut.set_events([inputEvent])


func _create_shortcut_input_even(key_codes: PackedInt32Array) -> InputEventKey:
	var inputEvent := InputEventKey.new()
	inputEvent.pressed = true
	for key_code in key_codes:
		match key_code:
			KEY_ALT:
				inputEvent.alt_pressed = true
			KEY_SHIFT:
				inputEvent.shift_pressed = true
			KEY_CTRL:
				inputEvent.ctrl_pressed = true
			_:
				inputEvent.keycode = key_code as Key
				inputEvent.physical_keycode = key_code as Key
	return inputEvent


@abstract func is_running() -> bool

@abstract func stop() -> void
