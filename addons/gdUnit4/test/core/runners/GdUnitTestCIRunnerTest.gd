extends GdUnitTestSuite


const DiscoverExampleTestSuite: GDScript = preload("res://addons/gdUnit4/test/core/discovery/resources/DiscoverExampleTestSuite.gd")


var _test_paths: PackedStringArray = []


func after_test() -> void:
	for test_path in _test_paths:
		GdUnitFileAccess.delete_directory(test_path)
	_test_paths.clear()


func _relative_path(path: String) -> String:
	_test_paths.append(path.get_slice("/", 0))
	return path


func _absolute_path(path: String) -> String:
	var absolute_path := ProjectSettings.globalize_path(path)
	_test_paths.append(absolute_path)
	return absolute_path


func _create_report_history(report_base_path: String, count: int) -> void:
	for index in range(1, count + 1):
		var report_dir := report_base_path.path_join(GdUnitConstants.REPORT_DIR_PREFIX + str(index))
		DirAccess.make_dir_recursive_absolute(report_dir)
		var file := FileAccess.open(report_dir.path_join("index.html"), FileAccess.WRITE)
		file.store_string("report")
		file.close()


func test_discover_tests_on_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	runner.add_test_suite("res://addons/gdUnit4/test/core/discovery/resources/")

	var tests := runner.discover_tests()
	if GdUnit4CSharpApiLoader.is_api_loaded():
		assert_array(tests).has_size(14)
	else:
		assert_array(tests).has_size(12)


func test_discover_tests_on_file() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	runner.add_test_suite("res://addons/gdUnit4/test/core/discovery/resources/DiscoverExampleTestSuite.gd")

	var tests := runner.discover_tests()
	assert_array(tests).has_size(12)


func test_discover_tests_on_path_and_skip_suite() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	runner.add_test_suite("res://addons/gdUnit4/test/core/discovery/resources/")
	runner.skip_test_suite("res://addons/gdUnit4/test/core/discovery/resources/DiscoverExampleTestSuite.gd")

	# It will be discover two tests from DiscoverExampleTestSuite.cs
	var tests := runner.discover_tests()
	if ClassDB.class_exists("CSharpScript"):
		assert_array(tests).has_size(2)
	else:
		assert_array(tests).is_empty()


func test_is_skipped_entire_suite_by_full_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	var tests: Array[GdUnitTestCase] = []
	GdUnitTestDiscoverer.discover_tests(DiscoverExampleTestSuite,
		func(test: GdUnitTestCase) -> void:
			tests.append(test)
	)

	runner.skip_test_suite("res://addons/gdUnit4/test/core/discovery/resources/DiscoverExampleTestSuite.gd")

	# Verify all tests are skipped
	for test in tests:
		assert_bool(runner.is_skipped(test)).override_failure_message("Expect '%s' is skipped" % test.test_name).is_true()


func test_is_skipped_entire_suite_by_name() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	var tests: Array[GdUnitTestCase] = []
	GdUnitTestDiscoverer.discover_tests(DiscoverExampleTestSuite,
		func(test: GdUnitTestCase) -> void:
			tests.append(test)
	)

	# Skip entire suite
	runner.skip_test_suite("DiscoverExampleTestSuite")
	# try also skip an non existing suite
	runner.skip_test_suite("NotExistingTestSuite")

	# Verify all tests are skipped
	for test in tests:
		assert_bool(runner.is_skipped(test)).override_failure_message("Expect '%s' is skipped" % test.test_name).is_true()


func test_is_skipped_single_test_by_full_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	var tests: Array[GdUnitTestCase] = []
	GdUnitTestDiscoverer.discover_tests(DiscoverExampleTestSuite,
		func(test: GdUnitTestCase) -> void:
			tests.append(test)
	)

	# Skip a single test by using full path
	runner.skip_test_suite("res://addons/gdUnit4/test/core/discovery/resources/DiscoverExampleTestSuite.gd:test_case1")
	# and by short suite name
	runner.skip_test_suite("DiscoverExampleTestSuite:test_case2")

	# Verify all tests are skipped
	for test in tests:
		if test.test_name in ["test_case1", "test_case2"]:
			assert_bool(runner.is_skipped(test)).override_failure_message("Expect '%s' is skipped" % test.test_name).is_true()
		else:
			assert_bool(runner.is_skipped(test)).override_failure_message("Expect '%s' is NOT skipped" % test.test_name).is_false()


#region set_report_dir
func test_set_report_dir_resource_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	runner.set_report_dir("res://reports/shard_1")
	assert_bool(runner.report_base_path.is_absolute_path()).is_true()
	assert_str(runner.report_base_path) \
		.not_contains("res:") \
		.ends_with("/reports/shard_1")


func test_set_report_dir_user_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	runner.set_report_dir("user://tmp/gdunit_test_reports")
	assert_bool(runner.report_base_path.is_absolute_path()).is_true()
	assert_str(runner.report_base_path) \
		.not_contains("user:") \
		.ends_with("/tmp/gdunit_test_reports")


func test_set_report_dir_absolute_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())
	var report_dir := _absolute_path("user://tmp/gdunit_test_reports")

	runner.set_report_dir(report_dir)
	assert_str(runner.report_base_path).is_equal(report_dir)


func test_set_report_dir_relative_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	runner.set_report_dir("reports/shard_1")
	assert_str(runner.report_base_path).is_equal("reports/shard_1")


func test_set_report_dir_absolute_root_path() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())

	runner.set_report_dir("/tmp/gdunit4/reports")
	assert_str(runner.report_base_path).is_equal("/tmp/gdunit4/reports")
#endregion


#region cleanup_report_history
func test_cleanup_report_history_on_absolute_report_dir() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())
	runner.set_report_dir(_absolute_path("user://tmp/gdunit_test_report_history"))
	runner.set_report_count("2")
	_create_report_history(runner.report_base_path, 5)

	runner.cleanup_report_history()
	assert_array(DirAccess.get_directories_at(runner.report_base_path)).contains_exactly_in_any_order(["report_4", "report_5"])


func test_cleanup_report_history_on_relative_report_dir() -> void:
	var runner: GdUnitTestCIRunner = auto_free(GdUnitTestCIRunner.new())
	runner.set_report_dir(_relative_path(".gdunit_test_reports/shard_1"))
	runner.set_report_count("2")
	_create_report_history(runner.report_base_path, 5)

	runner.cleanup_report_history()
	assert_array(DirAccess.get_directories_at(runner.report_base_path)).contains_exactly_in_any_order(["report_4", "report_5"])
#endregion


#region session runner registration
func test_new_runner_does_not_replace_the_session_runner() -> void:
	var session_runner: Object = Engine.get_meta(GdUnitSettings.GDUNIT_RUNNER)
	var runner := GdUnitTestCIRunner.new()

	assert_object(Engine.get_meta(GdUnitSettings.GDUNIT_RUNNER)).is_same(session_runner)
	runner.free()
	assert_object(Engine.get_meta(GdUnitSettings.GDUNIT_RUNNER, null)).is_same(session_runner)
#endregion
