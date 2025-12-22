class_name GdUnitCommandHandler
extends Object


const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")


const SETTINGS_SHORTCUT_MAPPING := {
	"N/A" : GdUnitShortcut.ShortCut.NONE,
	GdUnitSettings.SHORTCUT_INSPECTOR_RERUN_TEST : GdUnitShortcut.ShortCut.RERUN_TESTS,
	GdUnitSettings.SHORTCUT_INSPECTOR_RERUN_TEST_DEBUG : GdUnitShortcut.ShortCut.RERUN_TESTS_DEBUG,
	GdUnitSettings.SHORTCUT_INSPECTOR_RUN_TEST_OVERALL : GdUnitShortcut.ShortCut.RUN_TESTS_OVERALL,
	GdUnitSettings.SHORTCUT_INSPECTOR_RUN_TEST_STOP : GdUnitShortcut.ShortCut.STOP_TEST_RUN,
	GdUnitSettings.SHORTCUT_EDITOR_RUN_TEST : GdUnitShortcut.ShortCut.RUN_TESTCASE,
	GdUnitSettings.SHORTCUT_EDITOR_RUN_TEST_DEBUG : GdUnitShortcut.ShortCut.RUN_TESTCASE_DEBUG,
	GdUnitSettings.SHORTCUT_EDITOR_CREATE_TEST : GdUnitShortcut.ShortCut.CREATE_TEST,
	GdUnitSettings.SHORTCUT_FILESYSTEM_RUN_TEST : GdUnitShortcut.ShortCut.RUN_TESTSUITE,
	GdUnitSettings.SHORTCUT_FILESYSTEM_RUN_TEST_DEBUG : GdUnitShortcut.ShortCut.RUN_TESTSUITE_DEBUG
}

const CommandMapping := {
}

# the current test runner config
var _runner_config := GdUnitRunnerConfig.new()


# hold is current an test running
var _is_running: bool = false
var _commands := {}
var _shortcuts := {}
var _commnand_mappings: Dictionary[String, GdUnitBaseCommand]= {}

static func instance() -> GdUnitCommandHandler:
	return GdUnitSingleton.instance("GdUnitCommandHandler", func() -> GdUnitCommandHandler: return GdUnitCommandHandler.new())


@warning_ignore("return_value_discarded")
func _init() -> void:
	assert_shortcut_mappings(SETTINGS_SHORTCUT_MAPPING)

	GdUnitSignals.instance().gdunit_event.connect(_on_event)
	GdUnitSignals.instance().gdunit_client_disconnected.connect(_on_client_disconnected)
	GdUnitSignals.instance().gdunit_settings_changed.connect(_on_settings_changed)
	# preload previous test execution
	@warning_ignore("return_value_discarded")
	_runner_config.load_config()

	var test_session_command := GdUnitCommandTestSession.new()
	_register_command(test_session_command)
	_register_command(GdUnitCommandStopTestSession.new(test_session_command))
	_register_command(GdUnitCommandInspectorRunTests.new(test_session_command))
	_register_command(GdUnitCommandInspectorDebugTests.new(test_session_command))
	_register_command(GdUnitCommandScriptEditorRunTests.new(test_session_command))
	_register_command(GdUnitCommandScriptEditorDebugTests.new(test_session_command))
	_register_command(GdUnitCommandScriptEditorCreateTest.new())
	_register_command(GdUnitCommandFileSystemRunTests.new(test_session_command))
	_register_command(GdUnitCommandFileSystemDebugTests.new(test_session_command))
	_register_command(GdUnitCommandRunTestsOverall.new(test_session_command))

	# schedule discover tests if enabled and running inside the editor
	if Engine.is_editor_hint() and GdUnitSettings.is_test_discover_enabled():
		var timer :SceneTreeTimer = (Engine.get_main_loop() as SceneTree).create_timer(5)
		@warning_ignore("return_value_discarded")
		timer.timeout.connect(cmd_discover_tests)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for command: GdUnitBaseCommand in _commnand_mappings.values():
			if Engine.is_editor_hint():
				EditorInterface.get_command_palette().remove_command("GdUnit4/"+command.id)
			command.free()
		_commnand_mappings.clear()


func _do_process() -> void:
	check_test_run_stopped_manually()


# is checking if the user has press the editor stop scene
func check_test_run_stopped_manually() -> void:
	if is_test_running_but_stop_pressed():
		if GdUnitSettings.is_verbose_assert_warnings():
			push_warning("Test Runner scene was stopped manually, force stopping the current test run!")
		cmd_stop()


func is_test_running_but_stop_pressed() -> bool:
	return _is_running and not EditorInterface.is_playing_scene()


func assert_shortcut_mappings(mappings: Dictionary) -> void:
	for shortcut: int in GdUnitShortcut.ShortCut.values():
		assert(mappings.values().has(shortcut), "missing settings mapping for shortcut '%s'!" % GdUnitShortcut.ShortCut.keys()[shortcut])


func init_shortcuts() -> void:
	for shortcut: int in GdUnitShortcut.ShortCut.values():
		if shortcut == GdUnitShortcut.ShortCut.NONE:
			continue
		var property_name: String = SETTINGS_SHORTCUT_MAPPING.find_key(shortcut)
		var property := GdUnitSettings.get_property(property_name)
		var keys := GdUnitShortcut.default_keys(shortcut)
		if property != null:
			keys = property.value()
		var inputEvent := create_shortcut_input_even(keys)
		register_shortcut(shortcut, inputEvent)


func create_shortcut_input_even(key_codes: PackedInt32Array) -> InputEventKey:
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


# deprecated
func register_shortcut(p_shortcut: GdUnitShortcut.ShortCut, p_input_event: InputEvent) -> void:
	GdUnitTools.prints_verbose("register shortcut: '%s' to '%s'" % [GdUnitShortcut.ShortCut.keys()[p_shortcut], p_input_event.as_text()])
	var shortcut := Shortcut.new()
	shortcut.set_events([p_input_event])
	var command_name := get_shortcut_command(p_shortcut)
	_shortcuts[p_shortcut] = GdUnitShortcutAction.new(p_shortcut, shortcut, command_name)


func command_icon(command_id: String) -> Texture2D:
	if not _commnand_mappings.has(command_id):
		push_error("GdUnitCommandHandler:command_icon(): No command id '%s' is registered." % command_id)
		print_stack()
		return
	return _commnand_mappings[command_id].icon


func command_shortcut(command_id: String) -> Shortcut:
	if not _commnand_mappings.has(command_id):
		push_error("GdUnitCommandHandler:command_shortcut(): No command id '%s' is registered." % command_id)
		print_stack()
		return
	return _commnand_mappings[command_id].shortcut


func command_execute(...parameters: Array) -> void:
	if parameters.is_empty():
		push_error("Invalid arguments used on CommandHandler:execute()! Expecting [<command_id, args...>]")
		print_stack()
		return

	var command_id: String = parameters.pop_front()
	if not _commnand_mappings.has(command_id):
		push_error("GdUnitCommandHandler:command_execute(): No command id '%s' is registered." % command_id)
		print_stack()
		return
	_commnand_mappings[command_id].callv("execute", parameters)


# deprecated
func get_shortcut(shortcut_type: GdUnitShortcut.ShortCut) -> Shortcut:
	return get_shortcut_action(shortcut_type).shortcut


# deprecated
func get_shortcut_action(shortcut_type: GdUnitShortcut.ShortCut) -> GdUnitShortcutAction:
	return _shortcuts.get(shortcut_type)


# deprecated
func get_shortcut_command(p_shortcut: GdUnitShortcut.ShortCut) -> String:
	return CommandMapping.get(p_shortcut, "unknown command")


# deprecated
func register_command(p_command: GdUnitCommand) -> void:
	_commands[p_command.name] = p_command


func _register_command(command: GdUnitBaseCommand) -> void:
	# first verify the command is not already registerd
	if _commnand_mappings.has(command.id):
		push_error("GdUnitCommandHandler:_register_command(): Command with id '%s' is already registerd!" % command.id)
		return

	_commnand_mappings[command.id] = command
	if Engine.is_editor_hint():
		EditorInterface.get_base_control().add_child(command)
		EditorInterface.get_command_palette().add_command(command.id, "GdUnit4/"+command.id, command.execute, command.shortcut.get_as_text() if command.shortcut else "None")


func cmd_stop() -> void:
	var command: GdUnitCommandStopTestSession = _commnand_mappings[GdUnitCommandStopTestSession.ID]
	# don't stop if is already stopped
	if not command.is_running():
		return
	command.execute()


func cmd_discover_tests() -> void:
	await GdUnitTestDiscoverer.run()



func is_active_script_editor() -> bool:
	return EditorInterface.get_script_editor().get_current_editor() != null


func active_base_editor() -> TextEdit:
	return EditorInterface.get_script_editor().get_current_editor().get_base_editor()


func active_script() -> Script:
	return EditorInterface.get_script_editor().get_current_script()



################################################################################
# signals handles
################################################################################
func _on_event(event: GdUnitEvent) -> void:
	if event.type() == GdUnitEvent.SESSION_CLOSE:
		cmd_stop()


func _on_settings_changed(property: GdUnitProperty) -> void:

	for command: GdUnitBaseCommand in _commnand_mappings.values():
		command.update_shortcut()

	if property.name() == GdUnitSettings.TEST_DISCOVER_ENABLED:
		var timer :SceneTreeTimer = (Engine.get_main_loop() as SceneTree).create_timer(3)
		@warning_ignore("return_value_discarded")
		timer.timeout.connect(cmd_discover_tests)


################################################################################
# Network stuff
################################################################################
func _on_client_disconnected(_client_id: int) -> void:
	cmd_stop()
