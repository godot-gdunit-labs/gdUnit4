# GdUnit generated TestSuite
class_name GdUnitConsoleTestReporterTest
extends GdUnitTestSuite


var reporter := GdUnitConsoleTestReporter.new(GdUnitCSIMessageWriter.new())


func before_test() -> void:
	reporter.test_session = GdUnitTestSession.new([], "res://reports")
	reporter.on_gdunit_event(GdUnitInit.new())


func test_on_gdunit_event_init() -> void:
	assert_int(reporter.processed_suite_count()).is_equal(0)
	assert_int(reporter.total_test_count()).is_equal(0)
	assert_int(reporter.total_flaky_count()).is_equal(0)
	assert_int(reporter.total_error_count()).is_equal(0)
	assert_int(reporter.total_failure_count()).is_equal(0)
	assert_int(reporter.total_skipped_count()).is_equal(0)
	assert_int(reporter.total_orphan_count()).is_equal(0)
	assert_int(reporter.elapsed_time()).is_equal(0)


func test_on_gdunit_event_empty_test_suite() -> void:
	reporter.on_gdunit_event(GdUnitEvent.new().suite_before("res://tests/suite_a.gd", "suide_a", 0))
	reporter.on_gdunit_event(GdUnitEvent.new().suite_after("res://tests/suite_a.gd", "suide_a"))

	assert_int(reporter.processed_suite_count()).is_equal(1)
	assert_int(reporter.total_test_count()).is_equal(0)
	assert_int(reporter.total_flaky_count()).is_equal(0)
	assert_int(reporter.total_error_count()).is_equal(0)
	assert_int(reporter.total_failure_count()).is_equal(0)
	assert_int(reporter.total_skipped_count()).is_equal(0)
	assert_int(reporter.total_orphan_count()).is_equal(0)
	assert_int(reporter.elapsed_time()).is_equal(0)


func test_on_gdunit_event_full_test_suite() -> void:
	var test_id_a := GdUnitGUID.new()
	var test_id_b := GdUnitGUID.new()
	var test_id_c := GdUnitGUID.new()
	reporter.on_gdunit_event(GdUnitEvent.new().suite_before("res://tests/suite_a.gd", "suide_a", 0))
	reporter.on_gdunit_event(GdUnitEvent.new().test_before(test_id_a))
	reporter.on_gdunit_event(GdUnitEvent.new().test_after(test_id_a, "test_a"))
	reporter.on_gdunit_event(GdUnitEvent.new().test_before(test_id_b))
	reporter.on_gdunit_event(GdUnitEvent.new().test_after(test_id_b, "test_b"))
	reporter.on_gdunit_event(GdUnitEvent.new().test_before(test_id_c))
	reporter.on_gdunit_event(GdUnitEvent.new().test_after(test_id_c, "test_c"))
	reporter.on_gdunit_event(GdUnitEvent.new().suite_after("res://tests/suite_a.gd", "suide_a"))

	assert_int(reporter.processed_suite_count()).is_equal(1)
	assert_int(reporter.total_test_count()).is_equal(3)
	assert_int(reporter.total_flaky_count()).is_equal(0)
	assert_int(reporter.total_error_count()).is_equal(0)
	assert_int(reporter.total_failure_count()).is_equal(0)
	assert_int(reporter.total_skipped_count()).is_equal(0)
	assert_int(reporter.total_orphan_count()).is_equal(0)
	assert_int(reporter.elapsed_time()).is_equal(0)


func test_suite_status_is_passed_when_nothing_failed() -> void:
	var recorded := _run_suite({}, {})

	assert_array(recorded).is_equal(["PASSED", "PASSED"])


func test_suite_status_is_failed_when_a_test_failed() -> void:
	var recorded := _run_suite({GdUnitEvent.FAILED: true, GdUnitEvent.FAILED_COUNT: 1}, {})

	assert_array(recorded).is_equal(["FAILED", "FAILED"])


func test_suite_status_is_failed_when_a_test_errors() -> void:
	var recorded := _run_suite({GdUnitEvent.ERRORS: true, GdUnitEvent.ERROR_COUNT: 1}, {})

	assert_array(recorded).is_equal(["FAILED", "FAILED"])


func test_suite_status_is_failed_when_a_suite_hook_failed() -> void:
	var recorded := _run_suite({}, {GdUnitEvent.FAILED: true, GdUnitEvent.FAILED_COUNT: 1})

	assert_array(recorded).is_equal(["PASSED", "FAILED"])


## Runs one test inside one suite and returns the words printed at the status column, the test's
## first and the suite's second.
func _run_suite(test_statistics: Dictionary, suite_statistics: Dictionary) -> Array[String]:
	var writer := RecordingWriter.new()
	var console := GdUnitConsoleTestReporter.new(writer)
	console.test_session = GdUnitTestSession.new([], "res://reports")
	console.on_gdunit_event(GdUnitInit.new())

	var test_id := GdUnitGUID.new()
	console.on_gdunit_event(GdUnitEvent.new().suite_before("res://tests/suite_a.gd", "suite_a", 1))
	console.on_gdunit_event(GdUnitEvent.new().test_before(test_id))
	console.on_gdunit_event(GdUnitEvent.new().test_after(test_id, "test_a", test_statistics))
	console.on_gdunit_event(
		GdUnitEvent.new().suite_after("res://tests/suite_a.gd", "suite_a", suite_statistics)
	)
	return writer.printed_at


## A writer that keeps what was printed at the status column instead of printing it.
class RecordingWriter extends GdUnitMessageWriter:
	var printed_at: Array[String] = []


	func _print_stack_trace(_stack_trace: GdUnitStackTrace, _current_indent: int) -> void:
		pass


	func _print_message(_message: String, _color: Color, _indent: int, _flags: int) -> void:
		pass


	func _println_message(_message: String, _color: Color, _indent: int, _flags: int) -> void:
		pass


	func _print_at(
		message: String,
		_cursor_pos: int,
		_color: Color,
		_effect: GdUnitMessageWriter.Effect,
		_align: GdUnitMessageWriter.Align,
		_flags: int
	) -> void:
		printed_at.append(message)


	func clear() -> void:
		printed_at.clear()
