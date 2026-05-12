class_name GdUnitReportPanelTest
extends GdUnitTestSuite


var _panel: GdUnitReportPanel


func before_test() -> void:
	@warning_ignore("unsafe_method_access")
	_panel = load("res://addons/gdUnit4/src/ui/parts/GdUnitReportPanel.tscn").instantiate()
	add_child(_panel)


func after_test() -> void:
	remove_child(_panel)
	_panel.free()


func _build_report(message: String) -> GdUnitReport:
	return _build_report_with_frames(message, [])


func _build_report_with_frames(message: String, frames: Array[GdUnitStackTraceElement]) -> GdUnitReport:
	return GdUnitReport.new().from_error(
		GdUnitReport.FAILURE,
		GdUnitError.new(message, 1, GdUnitStackTrace.of(frames))
	)


#region clear
func test_clear_removes_all_report_children() -> void:
	_panel.show_report([_build_report("a"), _build_report("b")])
	_panel.clear()
	assert_int(_panel.report_list.get_child_count()).is_equal(0)
#endregion


#region show_report
func test_show_report_with_empty_list() -> void:
	_panel.show_report([])
	assert_int(_panel.report_list.get_child_count()).is_equal(0)


func test_show_report_adds_one_child_per_report() -> void:
	var reports: Array[GdUnitReport] = [
		_build_report("failure A"),
		_build_report("failure B"),
		_build_report("failure C"),
	]
	_panel.show_report(reports)
	assert_int(_panel.report_list.get_child_count()).is_equal(3)


func test_show_report_replaces_previous_reports() -> void:
	_panel.show_report([_build_report("first"), _build_report("second")])
	_panel.show_report([_build_report("only")])
	assert_int(_panel.report_list.get_child_count()).is_equal(1)
#endregion


#region build_report
func test_build_report_label_is_visible() -> void:
	var label: RichTextLabel = auto_free(_panel.build_report(_build_report("test message")))
	assert_bool(label.visible).is_true()


func test_build_report_parsed_text_contains_message() -> void:
	var label: RichTextLabel = auto_free(_panel.build_report(_build_report("expected failure text")))
	assert_str(label.get_parsed_text()).contains("expected failure text")


func test_build_report_with_stack_depth_of_1() -> void:
	var frames: Array[GdUnitStackTraceElement] = [
		GdUnitStackTraceElement.new("res://test/MyTest.gd", 42, "test_foo"),
	]
	var label: RichTextLabel = auto_free(_panel.build_report(_build_report_with_frames("assertion failed", frames)))
	assert_str(label.get_parsed_text()).is_equal("""
		assertion failed
			at test_foo in MyTest.gd : 42
		""".dedent().trim_prefix("\n"))


func test_build_report_with_stack_depth_of_3() -> void:
	var frames: Array[GdUnitStackTraceElement] = [
		GdUnitStackTraceElement.new("res://test/MyTest.gd", 42, "test_foo"),
		GdUnitStackTraceElement.new("res://suite/TestSuiteA.gd", 10, "before_test"),
		GdUnitStackTraceElement.new("res://runner/TestRunner.gd", 5, "run"),
	]
	var label: RichTextLabel = auto_free(_panel.build_report(_build_report_with_frames("assertion failed", frames)))
	assert_str(label.get_parsed_text()).is_equal("""
		assertion failed
			at test_foo in MyTest.gd : 42
			at before_test in TestSuiteA.gd : 10
			at run in TestRunner.gd : 5
		""".dedent().trim_prefix("\n"))
#endregion
