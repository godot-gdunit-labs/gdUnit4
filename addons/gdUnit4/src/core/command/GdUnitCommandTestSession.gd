class_name GdUnitCommandTestSession
extends GdUnitBaseCommand


const ID := "Start Test Session"


var _current_runner_process_id: int
var _is_running: bool
var _is_debug: bool
var _is_fail_fast: bool


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.NONE)
	_is_running = false
	_is_fail_fast = false


func is_running() -> bool:
	return _is_running


func stop() -> void:
	if not is_running():
		return

	if _is_debug:
		EditorInterface.stop_playing_scene()
	else:
		if OS.is_process_running(_current_runner_process_id):
			var result := OS.kill(_current_runner_process_id)
			if result != OK:
				push_error("ERROR checked stopping GdUnit Test Runner. error code: %s" % result)
			_current_runner_process_id = -1
	_is_running = false
	# We need finaly to send the test session close event because the current run is hard aborted.
	GdUnitSignals.instance().gdunit_event.emit(GdUnitSessionClose.new())


func execute(...parameters: Array) -> void:
	var tests_to_execute: Array[GdUnitTestCase] = parameters[0]
	_is_debug = parameters[1]

	_prepare_test_session(tests_to_execute)
	if _is_debug:
		EditorInterface.play_custom_scene("res://addons/gdUnit4/src/core/runners/GdUnitTestRunner.tscn")
	else:
		var arguments := Array()
		if OS.is_stdout_verbose():
			arguments.append("--verbose")
		arguments.append("--no-window")
		arguments.append("--path")
		arguments.append(ProjectSettings.globalize_path("res://"))
		arguments.append("res://addons/gdUnit4/src/core/runners/GdUnitTestRunner.tscn")
		_current_runner_process_id = OS.create_process(OS.get_executable_path(), arguments, false);
	_is_running = true


func _prepare_test_session(tests_to_execute: Array[GdUnitTestCase]) -> void:
	var server_port: int = Engine.get_meta("gdunit_server_port")
	var result := GdUnitRunnerConfig.new() \
		.set_server_port(server_port) \
		.do_fail_fast(_is_fail_fast) \
		.add_test_cases(tests_to_execute) \
		.save_config()
	if result.is_error():
		push_error(result.error_message())
		return
	# before start we have to save all scrpt changes
	ScriptEditorControls.save_all_open_script()
