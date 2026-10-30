extends GdUnitTestSuite

const TEST_COUNT := 500
const RUNS := 10
const MAX_OVERHEAD_PER_TEST_MS := 1.5


@warning_ignore("unused_parameter")
func before(do_skip := true, skip_reason := "Benchmark, set 'do_skip' to false to measure the auto save overhead.") -> void:
	pass


func test_auto_save_overhead_per_test() -> void:
	var tests := create_empty_tests_suite()
	await run_isolated(tests, false)

	var auto_save_off_ms := 0.0
	var auto_save_on_ms := 0.0
	for _run in RUNS:
		auto_save_off_ms += await measure_ms(tests, false)
		auto_save_on_ms += await measure_ms(tests, true)
	auto_save_off_ms /= RUNS
	auto_save_on_ms /= RUNS
	var overhead_per_test := (auto_save_on_ms - auto_save_off_ms) / TEST_COUNT
	prints(("%d empty tests, average of %d runs, auto save off: %.0f ms (%.2f ms/test),"
		+ " on: %.0f ms (%.2f ms/test), overhead: %.2f ms/test") % [
		TEST_COUNT, RUNS,
		auto_save_off_ms, auto_save_off_ms / TEST_COUNT,
		auto_save_on_ms, auto_save_on_ms / TEST_COUNT,
		overhead_per_test])

	assert_float(overhead_per_test)\
		.override_failure_message("Expecting the auto save overhead is less than %.2f ms per test, but was %.2f ms"
			% [MAX_OVERHEAD_PER_TEST_MS, overhead_per_test])\
		.is_less(MAX_OVERHEAD_PER_TEST_MS)


func create_empty_tests_suite() -> Array[GdUnitTestCase]:
	var source := "extends GdUnitTestSuite\n"
	for index in TEST_COUNT:
		source += "\n\nfunc test_empty_%03d() -> void:\n\tpass\n" % index
	var file := GdUnitFileAccess.create_temp_file("benchmark", "BenchmarkEmptyTestsSuite.gd")
	file.store_string(source)
	var suite_path := file.get_path()
	file.close()

	var loaded := GdUnitTestResourceLoader.load_tests(suite_path)
	return Array(loaded.values(), TYPE_OBJECT, "RefCounted", GdUnitTestCase)


func measure_ms(tests: Array[GdUnitTestCase], auto_save: bool) -> float:
	var time := LocalTime.now()
	await run_isolated(tests, auto_save)
	return time.elapsed_since_ms()


func run_isolated(tests: Array[GdUnitTestCase], auto_save: bool) -> void:
	await GdUnitThreadManager.run(
		"settings_snapshot_benchmark_%d" % randi(),
		func() -> void:
			var previous: Variant = ProjectSettings.get_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, true)
			ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, auto_save)
			var executor := GdUnitTestSuiteExecutor.new(true)
			await get_tree().process_frame
			await executor.run_and_wait(tests)
			ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, previous)
	)
