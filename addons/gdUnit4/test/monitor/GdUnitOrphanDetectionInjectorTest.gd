class_name GdUnitOrphanDetectionInjectorTest
extends GdUnitTestSuite


const EXAMPLE_SCRIPT_PATH := "res://addons/gdUnit4/test/resources/monitor/TestsWithOrphanNodes.gd"


func before() -> void:
	ProjectSettings.set_setting(GdUnitSettings.REPORT_ORPHANS, true)


func after() -> void:
	GdUnitOrphanDetectionInjector.cleanup()


func _collect_test_function_descriptors(script: GDScript) -> Array[GdFunctionDescriptor]:
	var test_names: PackedStringArray = []
	for function: Dictionary in script.get_script_method_list():
		var func_name: String = function["name"]
		if func_name.begins_with("test_"):
			test_names.append(func_name)
	return GdScriptParser.new().get_function_descriptors(script, test_names)


func test_intercept() -> void:
	var source_script: GDScript = load(EXAMPLE_SCRIPT_PATH)
	var source_code := source_script.source_code
	GdUnitOrphanDetectionInjector.intercept(source_script, _collect_test_function_descriptors(source_script))

	# Verify the patched source matches the expected output
	var patched_code := source_script.source_code
	var expected_source_code := FileAccess.get_file_as_string("res://addons/gdUnit4/test/resources/monitor/TestsWithOrphanNodesPatched.gd")
	assert_str(patched_code).is_equal(expected_source_code)

	var original_lines := source_code.split("\n")
	var patched_lines := patched_code.split("\n")

	var patched_row_index := 0

	# Verify the `resolve_original_line` maps patched line number to original source line number
	while patched_row_index < patched_lines.size():
		var patched_source_row := patched_lines[patched_row_index]
		# Skip injected code
		if patched_source_row.contains("# Injected collect orphan details"):
			patched_row_index += GdUnitOrphanDetectionInjector._injection_line_count
			continue

		var orig_line_num := GdUnitOrphanDetectionInjector.resolve_original_line(EXAMPLE_SCRIPT_PATH, patched_row_index)
		var original_source_row := original_lines[orig_line_num]
		assert_str(patched_source_row).is_equal(original_source_row)
		if is_failure():
			return
		patched_row_index += 1

	# Verify that a script which was not intercepted returns the line number unchanged
	assert_int(GdUnitOrphanDetectionInjector.resolve_original_line("res://unknown.gd", 42)).is_equal(42)
