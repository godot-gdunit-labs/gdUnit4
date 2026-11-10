class_name GdUnitTestResourceLoader
extends RefCounted

enum {
	GD_SUITE,
	CS_SUITE,
}

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")


static func load_test_suite(resource_path: String, script_type := GD_SUITE) -> Node:
	match script_type:
		GD_SUITE:
			return load_test_suite_gd(resource_path)
		CS_SUITE:
			return load_test_suite_cs(resource_path)
	assert("type '%s' is not implemented" % script_type)
	return null


static func load_tests(resource_path: String) -> Dictionary:
	var script := GdUnitTestSuiteScanner.load_with_disabled_warnings(resource_path)
	var discovered_tests := {}
	GdUnitTestDiscoverer.discover_tests(script, func(test: GdUnitTestCase) -> void:
		discovered_tests[test.display_name] = test
	)

	return discovered_tests


static func load_test_suite_gd(resource_path: String) -> GdUnitTestSuite:
	var script: GDScript = GdUnitTestSuiteScanner.load_with_disabled_warnings(resource_path)
	var discovered_tests: Array[GdUnitTestCase] = []
	GdUnitTestDiscoverer.discover_tests(script, func(test: GdUnitTestCase) -> void:
		discovered_tests.append(test)
	)
	# complete test suite wiht parsed test cases
	return GdUnitTestSuiteScanner.new().load_suite(script, discovered_tests)


static func load_test_suite_cs(resource_path: String) -> Node:
	if not GdUnit4CSharpApiLoader.is_api_loaded():
		return null
	var script: Script = ClassDB.instantiate("CSharpScript")
	script.source_code = GdUnitFileAccess.resource_as_string(resource_path)
	script.resource_path = resource_path
	script.reload()
	return null


static func load_cs_script(resource_path: String, debug_write := false) -> Script:
	if not GdUnit4CSharpApiLoader.is_api_loaded():
		return null
	var script: Script = ClassDB.instantiate("CSharpScript")
	script.source_code = GdUnitFileAccess.resource_as_string(resource_path)
	var script_resource_path := resource_path.replace(resource_path.get_extension(), "cs")
	if debug_write:
		script_resource_path = GdUnitFileAccess.create_temp_dir("test") + "/%s" % script_resource_path.get_file()
		print_debug("save resource:", script_resource_path)
		DirAccess.remove_absolute(script_resource_path)
		var err := ResourceSaver.save(script, script_resource_path)
		if err != OK:
			print_debug("Can't save debug resource", script_resource_path, "Error:", error_string(err))
		script.take_over_path(script_resource_path)
	else:
		script.take_over_path(resource_path)
	script.reload()
	return script
