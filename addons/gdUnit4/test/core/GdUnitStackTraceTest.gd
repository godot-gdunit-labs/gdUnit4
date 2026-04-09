class_name GdUnitStackTraceTest
extends GdUnitTestSuite

const __source = 'res://addons/gdUnit4/src/core/GdUnitStackTrace.gd'


#region helpers
func capture_stack() -> GdUnitStackTrace:
	return GdUnitStackTrace.new()


func capture_stack_1() -> GdUnitStackTrace:
	return capture_stack()


func capture_stack_2() -> GdUnitStackTrace:
	return capture_stack_1()


func capture_stack_3() -> GdUnitStackTrace:
	return capture_stack_2()


func capture_stack_4() -> GdUnitStackTrace:
	return capture_stack_3()


class InnerClass:

	static func capture_stack() -> GdUnitStackTrace:
		return GdUnitStackTrace.new()

#endregion


#region tests

func test_captures_stack_depth_0() -> void:
	var trace := GdUnitStackTrace.new()
	assert_int(trace.get_line_number()).is_equal(39)
	assert_str(trace.print_stack_trace())\
		.is_equal("\tat - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:39 in function 'test_captures_stack_depth_0'\n")


func test_captures_stack_depth_1() -> void:
	var trace := capture_stack()
	assert_int(trace.get_line_number()).is_equal(9)
	assert_str(trace.print_stack_trace())\
		.is_equal("""
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:9 in function 'capture_stack'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:46 in function 'test_captures_stack_depth_1'
			""".dedent().indent("\t").trim_prefix("\n"))


func test_captures_stack_depth_2() -> void:
	var trace := capture_stack_1()
	assert_int(trace.get_line_number()).is_equal(9)
	assert_str(trace.print_stack_trace())\
		.is_equal("""
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:9 in function 'capture_stack'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:13 in function 'capture_stack_1'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:56 in function 'test_captures_stack_depth_2'
			""".dedent().indent("\t").trim_prefix("\n"))


func test_captures_stack_depth_3() -> void:
	var trace := capture_stack_2()
	assert_int(trace.get_line_number()).is_equal(9)
	assert_str(trace.print_stack_trace())\
		.is_equal("""
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:9 in function 'capture_stack'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:13 in function 'capture_stack_1'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:17 in function 'capture_stack_2'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:67 in function 'test_captures_stack_depth_3'
			""".dedent().indent("\t").trim_prefix("\n"))


func test_captures_stack_depth_4() -> void:
	var trace := capture_stack_3()
	assert_int(trace.get_line_number()).is_equal(9)
	assert_str(trace.print_stack_trace())\
		.is_equal("""
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:9 in function 'capture_stack'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:13 in function 'capture_stack_1'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:17 in function 'capture_stack_2'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:21 in function 'capture_stack_3'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:79 in function 'test_captures_stack_depth_4'
			""".dedent().indent("\t").trim_prefix("\n"))


func test_captures_stack_depth_5() -> void:
	var trace := capture_stack_4()
	assert_int(trace.get_line_number()).is_equal(9)
	assert_str(trace.print_stack_trace())\
		.is_equal("""
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:9 in function 'capture_stack'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:13 in function 'capture_stack_1'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:17 in function 'capture_stack_2'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:21 in function 'capture_stack_3'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:25 in function 'capture_stack_4'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:92 in function 'test_captures_stack_depth_5'
			""".dedent().indent("\t").trim_prefix("\n"))


func test_mock_frames_are_filtered_from_stack_trace() -> void:
	var mock_node: Variant = mock(Node)
	assert_failure(func verify_call() -> void:
			@warning_ignore("unsafe_method_access")
			verify(mock_node, 1).set_process(true)\
		)\
		.has_stack_trace([
			GdUnitStackTraceElement.new("res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd", 109, "verify_call"),
			GdUnitStackTraceElement.new("res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd", 107, "test_mock_frames_are_filtered_from_stack_trace"),
		])


func test_spy_frames_are_filtered_from_stack_trace() -> void:
	var instance: Node = auto_free(Node.new())
	var spy_node: Variant = spy(instance)
	assert_failure(func verify_call() -> void:
			@warning_ignore("unsafe_method_access")
			verify(spy_node, 1).set_process(true)\
		)\
		.has_stack_trace([
			GdUnitStackTraceElement.new("res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd", 122, "verify_call"),
			GdUnitStackTraceElement.new("res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd", 120, "test_spy_frames_are_filtered_from_stack_trace"),
		])


func test_inner_class_frames_in_stack_trace() -> void:
	var trace := InnerClass.capture_stack()
	assert_int(trace.get_line_number()).is_equal(31)
	assert_str(trace.print_stack_trace())\
		.is_equal("""
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:31 in function 'capture_stack'
			at - res://addons/gdUnit4/test/core/GdUnitStackTraceTest.gd:131 in function 'test_inner_class_frames_in_stack_trace'
			""".dedent().indent("\t").trim_prefix("\n"))

#endregion
