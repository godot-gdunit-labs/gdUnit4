# This class provides a runner for scense to simulate interactions like keyboard or mouse
class_name GdUnitSceneRunnerImpl
extends GdUnitSceneRunner  # gdstyle:ignore-file=quality/max-public-methods

# mapping of mouse buttons and his masks
const MAP_MOUSE_BUTTON_MASKS := {
	MOUSE_BUTTON_LEFT: MOUSE_BUTTON_MASK_LEFT,
	MOUSE_BUTTON_RIGHT: MOUSE_BUTTON_MASK_RIGHT,
	MOUSE_BUTTON_MIDDLE: MOUSE_BUTTON_MASK_MIDDLE,
	# https://github.com/godotengine/godot/issues/73632
	MOUSE_BUTTON_WHEEL_UP: 1 << (MOUSE_BUTTON_WHEEL_UP - 1),
	MOUSE_BUTTON_WHEEL_DOWN: 1 << (MOUSE_BUTTON_WHEEL_DOWN - 1),
	MOUSE_BUTTON_XBUTTON1: MOUSE_BUTTON_MASK_MB_XBUTTON1,
	MOUSE_BUTTON_XBUTTON2: MOUSE_BUTTON_MASK_MB_XBUTTON2,
}

var _func_assert_impl: GDScript = ResourceLoader.load("res://addons/gdUnit4/src/asserts/GdUnitFuncAssertImpl.gd", "GDScript", ResourceLoader.CACHE_MODE_REUSE)
var _is_disposed := false
var _current_scene: Node = null
var _viewport: SubViewport = null
var _viewport_view: GdUnitSceneRunnerView = null
var _awaiter: GdUnitAwaiter = GdUnitAwaiter.new()
var _verbose: bool
var _simulate_start_time: LocalTime
var _last_input_event: InputEvent = null
var _mouse_button_on_press := []
var _key_on_press := []
var _action_on_press := []
var _curent_mouse_position: Vector2
# holds the touch position for each touch index
# { index: int = position: Vector2}
var _current_touch_position: Dictionary = {}
# holds the curretn touch drag position
var _current_touch_drag_position: Vector2 = Vector2.ZERO
# time factor settings
var _time_factor := 1.0
var _scene_auto_free := false
var _is_mouse_emulated := false


func _init(p_scene: Variant, p_verbose: bool, p_hide_push_errors := false) -> void:
	_verbose = p_verbose
	@warning_ignore("return_value_discarded")
	set_time_factor(1)
	# handle scene loading by resource path
	if typeof(p_scene) == TYPE_STRING:
		@warning_ignore("unsafe_cast")
		if not ResourceLoader.exists(p_scene as String):
			if not p_hide_push_errors:
				push_error("GdUnitSceneRunner: Can't load scene by given resource path: '%s'. The resource does not exists." % p_scene)
			return
		if not str(p_scene).ends_with(".tscn") and not str(p_scene).ends_with(".scn") and not str(p_scene).begins_with("uid://"):
			if not p_hide_push_errors:
				push_error("GdUnitSceneRunner: The given resource: '%s'. is not a scene." % p_scene)
			return
		@warning_ignore("unsafe_cast")
		_current_scene = (load(p_scene as String) as PackedScene).instantiate()
		_scene_auto_free = true
	else:
		# verify we have a node instance
		if not p_scene is Node:
			if not p_hide_push_errors:
				push_error("GdUnitSceneRunner: The given instance '%s' is not a Node." % p_scene)
			return
		_current_scene = p_scene
	if _current_scene == null:
		if not p_hide_push_errors:
			push_error("GdUnitSceneRunner: Scene must be not null!")
		return

	_viewport = _create_scene_viewport(_current_scene)
	_scene_tree().root.add_child(_viewport)

	if DisplayServer.get_name() != "headless":
		_viewport_view = GdUnitSceneRunnerView.new(_viewport)
		_scene_tree().root.add_child(_viewport_view)

	Engine.set_meta("GdUnitSceneRunner", self)

	_simulate_start_time = LocalTime.now()
	move_window_to_foreground()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and is_instance_valid(self):
		# reset time factor to normal
		_deactivate_time_factor()
		if is_instance_valid(_current_scene):
			move_window_to_background()
			if is_instance_valid(_viewport) and _current_scene.get_parent() == _viewport:
				_viewport.remove_child(_current_scene)
			# do only free scenes instanciated by this runner
			if _scene_auto_free:
				_current_scene.free()
		if is_instance_valid(_viewport_view):
			_scene_tree().root.remove_child(_viewport_view)
			_viewport_view.free()
		if is_instance_valid(_viewport):
			_scene_tree().root.remove_child(_viewport)
			_viewport.free()
		_is_disposed = true
		_current_scene = null
		_viewport = null
		_viewport_view = null
		Engine.remove_meta("GdUnitSceneRunner")


func _scene_tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


func _create_scene_viewport(current_scene: Node) -> SubViewport:
	var root := _scene_tree().root
	var viewport := SubViewport.new()
	viewport.name = "GdUnitSceneRunnerViewport"
	viewport.size = _viewport_size(root)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# the scene must run like in the game, Godot applies the project settings to the root viewport only, so take over all its settings
	for property: Dictionary in ClassDB.class_get_property_list("Viewport", true):
		var property_name: StringName = property["name"]
		var usage: int = property["usage"]
		if usage & PROPERTY_USAGE_STORAGE:
			viewport.set(property_name, root.get(property_name))
	viewport.gui_embed_subwindows = true
	viewport.notification(Node.NOTIFICATION_VP_MOUSE_ENTER)
	# do finally reset all open input events when the scene is removed
	@warning_ignore("return_value_discarded")
	viewport.child_exiting_tree.connect(
		func f(child: Node) -> void:
			if child == current_scene:
				_reset_input_to_default()
	)
	viewport.add_child(current_scene)
	return viewport


static func _viewport_size(root: Window) -> Vector2i:
	var content_scale_size := root.content_scale_size
	if root.content_scale_mode != Window.CONTENT_SCALE_MODE_DISABLED and content_scale_size.x > 0 and content_scale_size.y > 0:
		return content_scale_size
	@warning_ignore("unsafe_call_argument")
	var window_override := Vector2i(
		ProjectSettings.get_setting("display/window/size/window_width_override", 0),
		ProjectSettings.get_setting("display/window/size/window_height_override", 0)
	)
	if window_override.x > 0 and window_override.y > 0:
		return window_override
	@warning_ignore("unsafe_call_argument")
	return Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)


func await_input_processed() -> void:
	if scene() != null:
		Input.flush_buffered_events()
	await (Engine.get_main_loop() as SceneTree).process_frame
	await (Engine.get_main_loop() as SceneTree).physics_frame


@warning_ignore("return_value_discarded")
func simulate_action_pressed(action: String, event_index := -1) -> GdUnitSceneRunner:
	simulate_action_press(action, event_index)
	simulate_action_release(action, event_index)
	return self


func simulate_action_press(action: String, event_index := -1) -> GdUnitSceneRunner:
	_print_current_focus()
	var event := InputEventAction.new()
	event.pressed = true
	event.action = action
	event.event_index = event_index
	_action_on_press.append(action)
	return _handle_input_event(event)


func simulate_action_release(action: String, event_index := -1) -> GdUnitSceneRunner:
	_print_current_focus()
	var event := InputEventAction.new()
	event.pressed = false
	event.action = action
	event.event_index = event_index
	_action_on_press.erase(action)
	return _handle_input_event(event)


@warning_ignore("return_value_discarded")
func simulate_key_pressed(key_code: int) -> GdUnitSceneRunner:
	simulate_key_press(key_code)
	await _scene_tree().process_frame
	simulate_key_release(key_code)
	return self


func simulate_key_press(key_code: int) -> GdUnitSceneRunner:
	_print_current_focus()
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = key_code as Key
	event.physical_keycode = key_code as Key
	event.unicode = key_code
	event.set_alt_pressed(key_code == KEY_ALT)
	event.get_modifiers_mask()
	_apply_input_modifiers(event)
	_key_on_press.append(key_code)
	return _handle_input_event(event)


func simulate_key_release(key_code: int) -> GdUnitSceneRunner:
	_print_current_focus()
	var event := InputEventKey.new()
	event.pressed = false
	event.keycode = key_code as Key
	event.physical_keycode = key_code as Key
	event.unicode = key_code
	event.set_alt_pressed(key_code == KEY_ALT)
	_apply_input_modifiers(event)
	_key_on_press.erase(key_code)
	return _handle_input_event(event)


func set_mouse_position(pos: Vector2) -> GdUnitSceneRunner:
	var event := InputEventMouseMotion.new()
	event.position = pos
	event.global_position = _to_global_position(pos)
	_apply_input_modifiers(event)
	return _handle_input_event(event)


func get_mouse_position() -> Vector2:
	if _last_input_event is InputEventMouse:
		return (_last_input_event as InputEventMouse).position
	var current_scene := scene()
	if current_scene != null:
		return current_scene.get_viewport().get_mouse_position()
	return Vector2.ZERO


func get_global_mouse_position() -> Vector2:
	if _last_input_event is InputEventMouse:
		return (_last_input_event as InputEventMouse).global_position
	if is_instance_valid(_viewport):
		return _to_global_position(_viewport.get_mouse_position())
	return Vector2.ZERO


func simulate_mouse_move(position: Vector2) -> GdUnitSceneRunner:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = _to_global_position(position)
	event.relative = position - get_mouse_position()
	_apply_input_mouse_mask(event)
	_apply_input_modifiers(event)
	return _handle_input_event(event)


@warning_ignore("return_value_discarded")
func simulate_mouse_move_relative(relative: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	var tween := _scene_tree().create_tween()
	_curent_mouse_position = get_mouse_position()
	var final_position := _curent_mouse_position + relative
	tween.tween_property(self, "_curent_mouse_position", final_position, time).set_trans(trans_type)
	tween.play()

	while not get_mouse_position().is_equal_approx(final_position):
		simulate_mouse_move(_curent_mouse_position)
		await _scene_tree().process_frame
	return self


@warning_ignore("return_value_discarded")
func simulate_mouse_move_absolute(position: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	var tween := _scene_tree().create_tween()
	_curent_mouse_position = get_mouse_position()
	tween.tween_property(self, "_curent_mouse_position", position, time).set_trans(trans_type)
	tween.play()

	while not get_mouse_position().is_equal_approx(position):
		simulate_mouse_move(_curent_mouse_position)
		await _scene_tree().process_frame
	return self


@warning_ignore("return_value_discarded")
func simulate_mouse_button_pressed(button_index: MouseButton, double_click := false) -> GdUnitSceneRunner:
	simulate_mouse_button_press(button_index, double_click)
	simulate_mouse_button_release(button_index)
	return self


func simulate_mouse_button_press(button_index: MouseButton, double_click := false) -> GdUnitSceneRunner:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = true
	event.double_click = double_click
	_apply_input_mouse_position(event)
	_apply_input_mouse_mask(event)
	_apply_input_modifiers(event)
	_mouse_button_on_press.append(button_index)
	return _handle_input_event(event)


func simulate_mouse_button_release(button_index: MouseButton) -> GdUnitSceneRunner:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = false
	_apply_input_mouse_position(event)
	_apply_input_mouse_mask(event)
	_apply_input_modifiers(event)
	_mouse_button_on_press.erase(button_index)
	return _handle_input_event(event)


@warning_ignore("return_value_discarded")
func simulate_screen_touch_pressed(index: int, position: Vector2, double_tap := false) -> GdUnitSceneRunner:
	simulate_screen_touch_press(index, position, double_tap)
	simulate_screen_touch_release(index)
	return self


@warning_ignore("return_value_discarded")
func simulate_screen_touch_press(index: int, position: Vector2, double_tap := false) -> GdUnitSceneRunner:
	if is_emulate_mouse_from_touch():
		# we need to simulate in addition to the touch the mouse events
		_is_mouse_emulated = true
		set_mouse_position(position)
		simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
		_is_mouse_emulated = false
	# push touch press event at position
	var event := InputEventScreenTouch.new()
	event.window_id = scene().get_window().get_window_id()
	event.index = index
	event.position = position
	event.double_tap = double_tap
	event.pressed = true
	_current_scene.get_viewport().push_input(event)
	# save current drag position by index
	_current_touch_position[index] = position
	return self


@warning_ignore("return_value_discarded")
func simulate_screen_touch_release(index: int, double_tap := false) -> GdUnitSceneRunner:
	if is_emulate_mouse_from_touch():
		# we need to simulate in addition to the touch the mouse events
		_is_mouse_emulated = true
		simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
		_is_mouse_emulated = false
	# push touch release event at position
	var event := InputEventScreenTouch.new()
	event.window_id = scene().get_window().get_window_id()
	event.index = index
	event.position = get_screen_touch_drag_position(index)
	event.pressed = false
	event.double_tap = (_last_input_event as InputEventScreenTouch).double_tap if _last_input_event is InputEventScreenTouch else double_tap
	_current_scene.get_viewport().push_input(event)
	return self


func simulate_screen_touch_drag_relative(index: int, relative: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	var current_position: Vector2 = _current_touch_position[index]
	return await _do_touch_drag_at(index, current_position + relative, time, trans_type)


func simulate_screen_touch_drag_absolute(index: int, position: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
	return await _do_touch_drag_at(index, position, time, trans_type)


@warning_ignore("return_value_discarded")
func simulate_screen_touch_drag_drop(
	index: int,
	position: Vector2,
	drop_position: Vector2,
	time: float = 1.0,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
) -> GdUnitSceneRunner:
	simulate_screen_touch_press(index, position)
	return await _do_touch_drag_at(index, drop_position, time, trans_type)


@warning_ignore("return_value_discarded")
func simulate_screen_touch_drag(index: int, position: Vector2) -> GdUnitSceneRunner:
	if is_emulate_mouse_from_touch():
		_is_mouse_emulated = true
		simulate_mouse_move(position)
		_is_mouse_emulated = false
	var event := InputEventScreenDrag.new()
	event.window_id = scene().get_window().get_window_id()
	event.index = index
	event.position = position
	event.relative = _get_screen_touch_drag_position_or_default(index, position) - position
	event.velocity = event.relative / _scene_tree().root.get_process_delta_time()
	event.pressure = 1.0
	_current_touch_position[index] = position
	_current_scene.get_viewport().push_input(event)
	return self


func get_screen_touch_drag_position(index: int) -> Vector2:
	if _current_touch_position.has(index):
		return _current_touch_position[index]
	push_error("No touch drag position for index '%d' is set!" % index)
	return Vector2.ZERO


func is_emulate_mouse_from_touch() -> bool:
	return ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch", true)


func _get_screen_touch_drag_position_or_default(index: int, default_position: Vector2) -> Vector2:
	if _current_touch_position.has(index):
		return _current_touch_position[index]
	return default_position


@warning_ignore("return_value_discarded")
func _do_touch_drag_at(index: int, drag_position: Vector2, time: float, trans_type: Tween.TransitionType) -> GdUnitSceneRunner:
	# start draging
	var event := InputEventScreenDrag.new()
	event.window_id = scene().get_window().get_window_id()
	event.index = index
	event.position = get_screen_touch_drag_position(index)
	event.pressure = 1.0
	_current_touch_drag_position = event.position

	var tween := _scene_tree().create_tween()
	tween.tween_property(self, "_current_touch_drag_position", drag_position, time).set_trans(trans_type)
	tween.play()

	while not _current_touch_drag_position.is_equal_approx(drag_position):
		if is_emulate_mouse_from_touch():
			# we need to simulate in addition to the drag the mouse move events
			_is_mouse_emulated = true
			simulate_mouse_move(event.position)
			_is_mouse_emulated = false
		# send touche drag event to new position
		event.relative = _current_touch_drag_position - event.position
		event.velocity = event.relative / _scene_tree().root.get_process_delta_time()
		event.position = _current_touch_drag_position
		_current_scene.get_viewport().push_input(event)
		await _scene_tree().process_frame

	# finaly drop it
	if is_emulate_mouse_from_touch():
		_is_mouse_emulated = true
		simulate_mouse_move(drag_position)
		simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
		_is_mouse_emulated = false
	var touch_drop_event := InputEventScreenTouch.new()
	touch_drop_event.window_id = event.window_id
	touch_drop_event.index = event.index
	touch_drop_event.position = drag_position
	touch_drop_event.pressed = false
	_current_scene.get_viewport().push_input(touch_drop_event)
	await _scene_tree().process_frame
	return self


func set_time_factor(time_factor: float = 1.0) -> GdUnitSceneRunner:
	_time_factor = min(9.0, time_factor)
	_activate_time_factor()
	_print("set time factor: %f" % _time_factor)
	_print("set physics physics_ticks_per_second: %d" % (get_project_physics_ticks_per_second() * _time_factor))
	return self


func simulate_frames(frames: int, delta_milli: int = -1) -> GdUnitSceneRunner:
	var time_shift_frames: int = max(1, frames / _time_factor)
	for frame in time_shift_frames:
		if delta_milli == -1:
			await _scene_tree().process_frame
		else:
			await _scene_tree().create_timer(delta_milli * 0.001).timeout
	return self


func simulate_until_signal(signal_name: String, ...args: Array) -> GdUnitSceneRunner:
	await _awaiter.await_signal_idle_frames(scene(), signal_name, args, 10_000)
	return self


func simulate_until_object_signal(source: Object, signal_name: String, ...args: Array) -> GdUnitSceneRunner:
	await _awaiter.await_signal_idle_frames(source, signal_name, args, 10_000)
	return self


func await_func(func_name: String, ...args: Array) -> GdUnitFuncAssert:
	return _func_assert_impl.new(scene(), func_name, args)


func await_func_on(instance: Object, func_name: String, ...args: Array) -> GdUnitFuncAssert:
	return _func_assert_impl.new(instance, func_name, args)


func await_signal(signal_name: String, args := [], timeout := 2000) -> void:
	await _awaiter.await_signal_on(scene(), signal_name, args, timeout)


func await_signal_on(source: Object, signal_name: String, args := [], timeout := 2000) -> void:
	await _awaiter.await_signal_on(source, signal_name, args, timeout)


func move_window_to_foreground() -> GdUnitSceneRunner:
	if not Engine.is_embedded_in_editor() and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_move_to_foreground()
	return self


func move_window_to_background() -> GdUnitSceneRunner:
	if not Engine.is_embedded_in_editor() and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	return self


func _property_exists(name: String) -> bool:
	return scene().get_property_list().any(func(properties: Dictionary) -> bool: return properties["name"] == name)


func get_property(name: String) -> Variant:
	if not _property_exists(name):
		return "The property '%s' not exist checked loaded scene." % name
	return scene().get(name)


func set_property(name: String, value: Variant) -> bool:
	if not _property_exists(name):
		push_error("The property named '%s' cannot be set, it does not exist!" % name)
		return false
	scene().set(name, value)
	return true


func invoke(name: String, ...args: Array) -> Variant:
	if scene().has_method(name):
		return await scene().callv(name, args)
	return "The method '%s' not exist checked loaded scene." % name


func find_child(name: String, recursive: bool = true, owned: bool = false) -> Node:
	return scene().find_child(name, recursive, owned)


func _scene_name() -> String:
	if scene() == null:
		return "unknown"
	var scene_script: GDScript = scene().get_script()
	var scene_name: String = scene().get_name()
	if not scene_script:
		return scene_name
	if not scene_name.begins_with("@"):
		return scene_name
	return scene_script.resource_name.get_basename()


func _activate_time_factor() -> void:
	Engine.set_time_scale(_time_factor)
	Engine.set_physics_ticks_per_second((get_project_physics_ticks_per_second() * _time_factor) as int)


func _deactivate_time_factor() -> void:
	Engine.set_time_scale(1)
	Engine.set_physics_ticks_per_second(get_project_physics_ticks_per_second())


func get_project_physics_ticks_per_second() -> int:
	return ProjectSettings.get_setting("physics/common/physics_ticks_per_second")


# copy over current active modifiers
func _apply_input_modifiers(event: InputEvent) -> void:
	if _last_input_event is InputEventWithModifiers and event is InputEventWithModifiers:
		var last_input_event := _last_input_event as InputEventWithModifiers
		var modifier_event := event as InputEventWithModifiers
		modifier_event.meta_pressed = modifier_event.meta_pressed or last_input_event.meta_pressed
		modifier_event.alt_pressed = modifier_event.alt_pressed or last_input_event.alt_pressed
		modifier_event.shift_pressed = modifier_event.shift_pressed or last_input_event.shift_pressed
		modifier_event.ctrl_pressed = modifier_event.ctrl_pressed or last_input_event.ctrl_pressed
		# this line results into reset the control_pressed state!!!
		#event.command_or_control_autoremap = event.command_or_control_autoremap or _last_input_event.command_or_control_autoremap
	if _last_input_event is InputEventKey and event is InputEventWithModifiers:
		var last_input_event := _last_input_event as InputEventKey
		var modifier_event := event as InputEventWithModifiers
		modifier_event.shift_pressed = modifier_event.shift_pressed or last_input_event.keycode == KEY_SHIFT
		modifier_event.alt_pressed = modifier_event.alt_pressed or last_input_event.keycode == KEY_ALT
		modifier_event.ctrl_pressed = modifier_event.ctrl_pressed or last_input_event.keycode == KEY_CTRL
		modifier_event.meta_pressed = modifier_event.meta_pressed or last_input_event.keycode == KEY_META


# copy over current active mouse mask and combine with curren mask
func _apply_input_mouse_mask(event: InputEvent) -> void:
	# first apply last mask
	if _last_input_event is InputEventMouse and event is InputEventMouse:
		(event as InputEventMouse).button_mask |= (_last_input_event as InputEventMouse).button_mask
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		var button_mask: int = MAP_MOUSE_BUTTON_MASKS.get(mouse_event.get_button_index(), 0)
		if mouse_event.is_pressed():
			mouse_event.button_mask |= button_mask
		else:
			mouse_event.button_mask ^= button_mask


# copy over last mouse position if need
func _apply_input_mouse_position(event: InputEvent) -> void:
	if _last_input_event is InputEventMouse and event is InputEventMouseButton:
		var last_input_event := _last_input_event as InputEventMouse
		var mouse_event := event as InputEventMouseButton
		mouse_event.position = last_input_event.position
		mouse_event.global_position = last_input_event.global_position


## The scene viewport is shown scaled in the window, Godot reports the global position of mouse events in window coordinates
func _to_global_position(viewport_position: Vector2) -> Vector2:
	if is_instance_valid(_viewport_view):
		return _viewport_view.position + _viewport_view.to_view_position(viewport_position)
	return viewport_position


## handle input action via Input modifieres
func _handle_actions(event: InputEventAction) -> bool:
	if not InputMap.event_is_action(event, event.action, true):
		return false
	_print("	process action %s (%s) <- %s" % [scene(), _scene_name(), event.as_text()])
	if event.is_pressed():
		Input.action_press(event.action, event.get_strength())
	else:
		Input.action_release(event.action)
	return true


# for handling read https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html?highlight=inputevent#how-does-it-work
@warning_ignore("return_value_discarded")
func _handle_input_event(event: InputEvent) -> GdUnitSceneRunner:
	if _is_mouse_emulated and event is InputEventMouse:
		event.device = InputEvent.DEVICE_ID_EMULATION
	Input.parse_input_event(event)

	if event is InputEventAction:
		_handle_actions(event as InputEventAction)

	var current_scene := scene()
	if is_instance_valid(current_scene):
		Input.flush_buffered_events()
		var touch_event := _emulated_touch_event(event)
		if touch_event != null:
			_viewport.push_input(touch_event)
		_viewport.push_input(event)
		_print("	process event %s (%s) <- %s" % [current_scene, _scene_name(), event.as_text()])

	# save last input event needs to be merged with next InputEventMouseButton
	_last_input_event = event
	return self


## Godot sends the touch events emulated from mouse input to the root window only, the scene viewport needs its own
static func _emulated_touch_event(event: InputEvent) -> InputEvent:
	if not Input.is_emulating_touch_from_mouse() or event.device == InputEvent.DEVICE_ID_EMULATION:
		return null
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mouse_button := event as InputEventMouseButton
		var touch := InputEventScreenTouch.new()
		touch.device = InputEvent.DEVICE_ID_EMULATION
		touch.position = mouse_button.position
		touch.pressed = mouse_button.pressed
		touch.canceled = mouse_button.canceled
		touch.double_tap = mouse_button.double_click
		return touch
	if event is InputEventMouseMotion and (event as InputEventMouseMotion).button_mask & MOUSE_BUTTON_MASK_LEFT:
		var mouse_motion := event as InputEventMouseMotion
		var drag := InputEventScreenDrag.new()
		drag.device = InputEvent.DEVICE_ID_EMULATION
		drag.position = mouse_motion.position
		drag.relative = mouse_motion.relative
		drag.screen_relative = mouse_motion.screen_relative
		drag.velocity = mouse_motion.velocity
		drag.screen_velocity = mouse_motion.screen_velocity
		drag.pressure = mouse_motion.pressure
		drag.tilt = mouse_motion.tilt
		drag.pen_inverted = mouse_motion.pen_inverted
		return drag
	return null


@warning_ignore("return_value_discarded")
func _reset_input_to_default() -> void:
	# reset all mouse button to inital state if need
	for m_button: int in _mouse_button_on_press.duplicate():
		if Input.is_mouse_button_pressed(m_button):
			simulate_mouse_button_release(m_button)
	_mouse_button_on_press.clear()

	for key_scancode: int in _key_on_press.duplicate():
		if Input.is_key_pressed(key_scancode):
			simulate_key_release(key_scancode)
	_key_on_press.clear()

	for action: String in _action_on_press.duplicate():
		if Input.is_action_pressed(action):
			simulate_action_release(action)
	_action_on_press.clear()

	if is_instance_valid(_current_scene):
		Input.flush_buffered_events()
	_last_input_event = null


func _print(message: String) -> void:
	if _verbose:
		prints(message)


func _print_current_focus() -> void:
	if not _verbose:
		return
	var focused_node := scene().get_viewport().gui_get_focus_owner()
	if focused_node:
		prints("	focus checked %s" % focused_node)
	else:
		prints("	no focus set")


func scene() -> Node:
	if is_instance_valid(_current_scene):
		return _current_scene
	if not _is_disposed:
		push_error("The current scene instance is not valid anymore! check your test is valid. e.g. check for missing awaits.")
	return null
