class_name GdUnitCommandInspectorRerunTestsUntilFailure
extends GdUnitBaseCommand


signal session_closed()


const GdUnitInspectorTreeMainPanel := preload("res://addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.gd")
const ID := "Rerun Inspector Tests Until Failure"


var _current_execution_count := 0
var saved_flaky_settings: bool
var force_stop := false


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.RERUN_TESTS_UNTIL_FAILURE)
	icon = GdUnitUiTools.get_icon("Play")


func execute(..._parameters: Array) -> void:
	force_stop = false
	_prepare_test_session()

	var rerun_until_failure_count := GdUnitSettings.get_rerun_max_retries()
	saved_flaky_settings = ProjectSettings.get_setting(GdUnitSettings.TEST_FLAKY_CHECK)
	ProjectSettings.set_setting(GdUnitSettings.TEST_FLAKY_CHECK, false)

	if not GdUnitSignals.instance().gdunit_event.is_connected(_on_test_event):
		GdUnitSignals.instance().gdunit_event.connect(_on_test_event)
	_current_execution_count = 1

	while force_stop == false and _current_execution_count <= rerun_until_failure_count:
		EditorInterface.play_custom_scene("res://addons/gdUnit4/src/core/runners/GdUnitTestRunner.tscn")
		await session_closed
		_current_execution_count += 1

	stop()


func _do_stop() -> void:
	force_stop = true
	if GdUnitSignals.instance().gdunit_event.is_connected(_on_test_event):
		GdUnitSignals.instance().gdunit_event.disconnect(_on_test_event)
	if EditorInterface.is_playing_scene():
		GdUnitCommandTestSession.force_pause_scene()
		EditorInterface.stop_playing_scene()
	ProjectSettings.set_setting(GdUnitSettings.TEST_FLAKY_CHECK, saved_flaky_settings)
	GdUnitSignals.instance().gdunit_event.emit(GdUnitSessionClose.new())


func _prepare_test_session() -> void:
	var base_control := EditorInterface.get_base_control()
	var inspector: GdUnitInspectorTreeMainPanel = base_control.get_meta("GdUnit4Inspector")
	var selected_item := inspector._tree.get_selected()
	var tests_to_execute := inspector.collect_test_cases(selected_item)
	var server_port: int = Engine.get_meta("gdunit_server_port")
	var result := GdUnitRunnerConfig.new() \
		.set_server_port(server_port) \
		.do_fail_fast(true) \
		.add_test_cases(tests_to_execute) \
		.save_config()
	if result.is_error():
		push_error(result.error_message())
		return
	# before start we have to save all scrpt changes
	GdUnitScriptEditorControls.save_all_open_script()


func _on_test_event(event: GdUnitEvent) -> void:
	if event.type() == GdUnitEvent.SESSION_START:
		GdUnitSignals.instance().gdunit_message.emit("[color=RED]Execution Mode: ReRun until failure! (iteration %d:%d)[/color]" % [
			_current_execution_count, GdUnitSettings.get_rerun_max_retries()])
	if event.type() == GdUnitEvent.SESSION_CLOSE:
		session_closed.emit()
	if event.type() == GdUnitEvent.TESTCASE_AFTER:
		if not event.is_success():
			GdUnitSignals.instance().gdunit_message.emit(" [color=RED](iteration: %d)[/color]" % _current_execution_count)
			force_stop = true
