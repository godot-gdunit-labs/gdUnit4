# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_discover_tests_with_fuzzers() -> void:
	# Setup
	var script: GDScript = load("res://addons/gdUnit4/test/core/parse/resources/TestSuiteWithFuzzers.gd")

	# Act
	var tests := GdUnitTestDiscoverer.discover_tests_from_gd_script(script)

	# Verify
	assert_array(tests)\
		.extractv(
			extr("suite_name"),
			extr("test_name"),
			extr("source_file"),
			extr("line_number"),
			extr("attribute_index"))\
		.contains_exactly(
			tuple("TestSuiteWithFuzzers", "test_do_skip_as_first_param", script.resource_path, 4, -1),
			tuple("TestSuiteWithFuzzers", "test_do_skip_in_middle", script.resource_path, 11, -1),
			tuple("TestSuiteWithFuzzers", "test_do_skip_as_last_param", script.resource_path, 18, -1),
		)


func test_discover_tests_with_static_parameterset() -> void:
	# Setup
	var script: GDScript = load("res://addons/gdUnit4/test/core/parse/resources/TestSuiteWithStaticParameterSet.gd")

	# Act
	var tests := GdUnitTestDiscoverer.discover_tests_from_gd_script(script)

	# Verify
	assert_array(tests)\
		.extractv(
			extr("suite_name"),
			extr("test_name"),
			extr("source_file"),
			extr("line_number"),
			extr("attribute_index"))\
		.contains(
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_bool_value", script.resource_path, 5, 0),
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_bool_value", script.resource_path, 5, 1),
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_int_values", script.resource_path, 12, 0),
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_int_values", script.resource_path, 12, 1),
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_int_values", script.resource_path, 12, 2),
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_float_values", script.resource_path, 20, 0),
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_float_values", script.resource_path, 20, 1),
			tuple("TestSuiteWithStaticParameterSet", "test_parameterized_float_values", script.resource_path, 20, 2),
		)
