# GdUnit generated TestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


func test_of_creates_element_from_dict() -> void:
	var data := {"source": "res://test.gd", "line": 42, "function": "my_func"}
	assert_that(GdUnitStackTraceElement.of(data)) \
		.is_equal(GdUnitStackTraceElement.new("res://test.gd", 42, "my_func"))
