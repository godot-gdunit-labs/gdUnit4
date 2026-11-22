class_name GdUnitBenchmarkEnvironmentTest
extends GdUnitTestSuite


#region current
func test_current_with_active_debugger() -> void:
	assert_bool(GdUnitBenchmarkEnvironment.current(true).debugger_active).is_true()


func test_current_without_active_debugger() -> void:
	assert_bool(GdUnitBenchmarkEnvironment.current(false).debugger_active).is_false()


func test_current_debugger_from_engine() -> void:
	assert_bool(GdUnitBenchmarkEnvironment.current().debugger_active).is_equal(EngineDebugger.is_active())


func test_current_values() -> void:
	var environment := GdUnitBenchmarkEnvironment.current(false)
	var info := Engine.get_version_info()

	assert_str(environment.gdunit4_version).is_equal(str(GdUnit4Version.current()))
	assert_str(environment.godot_version).is_equal("v%d.%d.%d.%s" % [info["major"], info["minor"], info["patch"], info["status"]])
	assert_bool(environment.editor_build).is_equal(OS.has_feature("editor"))
	assert_bool(environment.debug_build).is_equal(OS.is_debug_build())
	assert_str(environment.os_name).is_equal(OS.get_name())
	assert_str(environment.os_version).is_equal(OS.get_version())
	assert_str(environment.processor_name).is_equal(OS.get_processor_name())
	assert_int(environment.processor_count).is_equal(OS.get_processor_count())
	assert_bool(environment.headless).is_equal(DisplayServer.get_name() == "headless")
	assert_str(environment.time).is_not_empty()


func test_godot_version_format() -> void:
	var info := { "major": 4, "minor": 7, "patch": 1, "status": "stable" }

	assert_str(GdUnitBenchmarkEnvironment._godot_version(info)).is_equal("v4.7.1.stable")
	assert_str(GdUnitBenchmarkEnvironment._godot_version({})).is_equal("v0.0.0.")
#endregion


#region round trip
func test_round_trip_with_active_debugger() -> void:
	var environment := GdUnitBenchmarkEnvironment.current(true)

	var restored := GdUnitBenchmarkEnvironment.deserialize(GdUnitBenchmarkResultTest.json_round_trip(environment.serialize()))

	assert_that(restored).is_equal(environment)
	assert_bool(restored.debugger_active).is_true()
	assert_int(typeof(restored.processor_count)).is_equal(TYPE_INT)


func test_round_trip_without_active_debugger() -> void:
	var environment := GdUnitBenchmarkEnvironment.current(false)

	var restored := GdUnitBenchmarkEnvironment.deserialize(GdUnitBenchmarkResultTest.json_round_trip(environment.serialize()))

	assert_that(restored).is_equal(environment)
	assert_bool(restored.debugger_active).is_false()


func test_deserialize_empty() -> void:
	assert_that(GdUnitBenchmarkEnvironment.deserialize({})).is_equal(GdUnitBenchmarkEnvironment.new())
#endregion
