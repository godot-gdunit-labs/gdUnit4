extends GdUnitTestSuite

const CASES: Array = [[1], [2], [3]]


@warning_ignore("unused_parameter")
func test_with_constant(
	value: int, _test_parameters := CASES
) -> void:
	pass


@warning_ignore("unused_parameter")
func test_with_typed_constant(
	value: int,
	_test_parameters: Array = CASES
) -> void:
	pass


@warning_ignore("unused_parameter")
func test_with_trailing_comma(
	value: int,
	_test_parameters := CASES,
) -> void:
	pass


@warning_ignore("unused_parameter")
func test_with_function(
	value: int, _test_parameters := cases()
) -> void:
	pass


func cases() -> Array:
	return [[1], [2]]
