# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdUnit4CSharpApiLoaderTest
extends GdUnitTestSuite

# TestSuite generated from
const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")


func before(_do_skip := not GdUnit4CSharpApiLoader.is_api_loaded(), _skip_reason := "Do run only for Godot .Net version") -> void:
	pass


func test_is_engine_version_supported(version :int, expected :bool, _test_parameters := [
	[0x40100, false],
	[0x40500, false],
	[0x40603, false],
	[0x40700, true],
	[0x40701, true],
	[0x40800, true]]) -> void:

	assert_bool(GdUnit4CSharpApiLoader.is_engine_version_supported(version)).is_equal(expected)


func test_api_version() -> void:
	assert_str(GdUnit4CSharpApiLoader.version()).starts_with("5.1.0")


func test_create_test_suite() -> void:
	var temp := create_temp_dir("examples")
	var result := GdUnitFileAccess.copy_file("res://addons/gdUnit4/test/resources/core/sources/TestPerson.cs", temp)
	assert_result(result).is_success()

	var example_source_cs := result.value_as_string()
	var source := load(example_source_cs)
	var test_suite_path := GdUnitTestSuiteScanner.resolve_test_suite_path(source.resource_path, "test")
	result = GdUnit4CSharpApiLoader.create_test_suite(source.resource_path, 18, test_suite_path)

	assert_result(result).is_success()
	var info: Dictionary = result.value()
	assert_str(info.get("path")).is_equal("user://tmp/test/examples/TestPersonTest.cs")
	assert_int(info.get("line")).is_equal(16)


func test_discover_tests() -> void:
	var script: Script = load("res://addons/gdUnit4/test/dotnet/ExampleTestSuite.cs")
	var tests := GdUnit4CSharpApiLoader.discover_tests(script)

	assert_array(tests).has_size(14)\
		.contains([any_class(GdUnitTestCase)])
