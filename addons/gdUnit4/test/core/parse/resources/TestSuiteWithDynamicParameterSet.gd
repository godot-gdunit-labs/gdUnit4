extends GdUnitTestSuite


func _test_parameters_untyped() -> Array:
	return [
		["test_a", auto_free(Node2D.new()), Node2D],
		["test_b", auto_free(Node3D.new()), Node3D],
	]


func _test_parameters_typed() -> Array[Array]:
	return [
		["test_a", auto_free(Node2D.new()), Node2D],
		["test_b", auto_free(Node3D.new()), Node3D],
	]


func _dynamic_parameterset(count: int) -> Array[Array]:
	#print_stack()
	var iterations: Array[Array] = []
	for i in range(count):
		iterations.append(["name_%s"%i, i, i])
	return iterations


@warning_ignore("unused_parameter")
func test_with_dynamic_parameters_typed_array(name_: String, value: Variant, expected: Variant, _test_parameters := _test_parameters_typed()) -> void:
	prints("test_with_dynamic_parameters_typed_array", name_, value, expected, _test_parameters)


@warning_ignore("unused_parameter")
func test_with_dynamic_parameters_untyped_array(name_: String, value: Variant, expected: Variant, _test_parameters := _test_parameters_untyped()) -> void:
	prints("test_with_dynamic_parameters_untyped_array", name_, value, expected, _test_parameters)

@warning_ignore("unused_parameter")
func test_with_dynamic_parameterset(name_: String, value: Variant, expected: Variant, _test_parameters := _dynamic_parameterset(10)) -> void:
	prints("test_with_dynamic_parameterset", name_, value, expected, _test_parameters)
