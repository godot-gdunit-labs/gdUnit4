# GdUnit generated TestSuite
class_name GdUnitCommandTestSessionTest
extends GdUnitTestSuite


const __source = "res://addons/gdUnit4/src/core/command/GdUnitCommandTestSession.gd"


var _command: GdUnitCommandTestSession


func before_test() -> void:
	_command = GdUnitCommandTestSession.new()


func after_test() -> void:
	_command.free()


#region runner process guard
func test_runner_process_id_initialized_to_invalid() -> void:
	# Must not default to `0`, otherwise stop() would call OS.kill(0) on the calling process group.
	assert_int(_command._current_runner_process_id).is_equal(-1)


func test_is_valid_runner_process_rejects_default_pid() -> void:
	# `0` is the uninitialized/debug-mode value and must never be treated as a killable process.
	assert_bool(GdUnitCommandTestSession._is_valid_runner_process(0)).is_false()


func test_is_valid_runner_process_rejects_negative_pid() -> void:
	assert_bool(GdUnitCommandTestSession._is_valid_runner_process(-1)).is_false()
#endregion
