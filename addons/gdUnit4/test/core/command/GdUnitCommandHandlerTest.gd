
# GdUnit generated TestSuite
extends GdUnitTestSuite


var _handler :GdUnitCommandHandler


func before() -> void:
	_handler = GdUnitCommandHandler.new()


func after() -> void:
	_handler.free()


func test_command_shortcut() -> void:
	assert_str(_handler.command_shortcut(GdUnitCommandRunTestsOverall.ID).get_as_text()).is_equal("Alt+F7")
	assert_str(_handler.command_shortcut(GdUnitCommandStopTestSession.ID).get_as_text()).is_equal("Alt+F8")



@warning_ignore('unused_parameter')
func test_create_shortcuts_defaults(shortcut :GdUnitShortcut.ShortCut, expected :String, test_parameters := [
	[GdUnitShortcut.ShortCut.RUN_TESTCASE, "GdUnitShortcutAction: RUN_TESTCASE (Ctrl+Alt+F5) -> Run TestCases"],
	[GdUnitShortcut.ShortCut.RUN_TESTCASE_DEBUG, "GdUnitShortcutAction: RUN_TESTCASE_DEBUG (Ctrl+Alt+F6) -> Run TestCases (Debug)"],
	[GdUnitShortcut.ShortCut.CREATE_TEST, "GdUnitShortcutAction: CREATE_TEST (Ctrl+Alt+F10) -> Create TestCase"]]) -> void:

	if OS.get_name().to_lower() == "macos":
		expected.replace("Ctrl", "Command")

	var action := _handler.get_shortcut_action(shortcut)
	assert_that(str(action)).is_equal(expected)


## actually needs to comment out, it produces a lot of leaked instances
func _test__check_test_run_stopped_manually() -> void:
	var inspector :GdUnitCommandHandler = mock(GdUnitCommandHandler, CALL_REAL_FUNC)

	# simulate no test is running
	do_return(false).on(inspector).is_test_running_but_stop_pressed()
	inspector.check_test_run_stopped_manually()
	verify(inspector, 0).cmd_stop(any_int())

	# simulate the test runner was manually stopped by the editor
	do_return(true).on(inspector).is_test_running_but_stop_pressed()
	inspector.check_test_run_stopped_manually()
	verify(inspector, 1).cmd_stop()
