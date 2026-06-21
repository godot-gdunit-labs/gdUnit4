# GdUnit generated TestSuite
extends GdUnitTestSuite


var example_parameters := [
	'[auto_free(Node.new()), Node]',
	'[auto_free(Node3D.new()), Node3D]',
	'["abc", "String"]',
	'[_x, "Integer"]',
	'[_obj, Node2D]',
	'[TestObj.new(), TestObj]',
	'[Vector3(1,1,1), Vector2(2,2)]',
	'[Color(1,1,1), _color]',
	'_test_set_a]'
	]

class TestObj:

	func _init() -> void:
		pass


class TestObjNamed extends RefCounted:
	var _value: String

	func _init(value: String) -> void:
		_value = value

	func _to_string() -> String:
		return _value


@warning_ignore_start("unused_private_class_variable")
var _x := 42
var _obj: Node2D
var _color := Color.RED
var _test_set_a := [Color(1,1,1), Color(.1,.1,.1)]
var _test_param1 := 10
var _test_param2 := 20
@warning_ignore_restore("unused_private_class_variable")

func before() -> void:
	_obj = auto_free(Node2D.new())
	_test_param1 = 11


func test_before() -> void:
	_test_param2 = 22


func build_param(value: float) -> Vector3:
	return Vector3(value, value, value)


func test_example_a(_a: int, _b: int, _test_parameters := [[1, 2], [3, 4]]) -> void:
	pass


func test_example_b(_a: Vector2, _b: Vector2, _test_parameters := [
	[Vector2.ZERO, Vector2.ONE], [Vector2(1.1, 3.2), Vector2.DOWN]]) -> void:
	pass


func test_example_c(_a: Object, _b: Object, _test_parameters := [
	[Resource.new(), Resource.new()],
	[Resource.new(), null]
	]) -> void:
	pass


func test_resolve_parameters_static(_a: int, _b: int, _test_parameters := [
	[1, 10],
	[2, 20]
	]) -> void:
	pass


func test_resolve_parameters_at_runtime(_a: int, _b: int, _test_parameters := [
	[1, _test_param1],
	[2, _test_param2],
	[3, 30]
	]) -> void:
	pass


func test_parameterized_with_comments(_a: int, _b: int, _c: String, _expected: int, _test_parameters := [
	# before data set
	[1, 2, '3', 6], # after data set
	# between data sets
	[3, 4, '5', 11],
	[6, 7, 'string #ABCD', 21], # dataset with [comment] sign
	[6, 7, "string #ABCD", 21] # dataset with "comment" sign
	#eof
]) -> void:
	pass


func test_example_d(_a: Vector3, _b: Vector3, _test_parameters := [
	[build_param(1), build_param(3)],
	[Vector3.BACK, Vector3.UP]
	]) -> void:
	pass


func test_example_e(_a: Object, _b: Object, _expected: String, _test_parameters := [
	[TestObjNamed.new("abc"), TestObjNamed.new("def"), "abcdef"]]) -> void:
	pass


#region get_parameters

func test_get_parameters() -> void:
	var resolver := GdInlineParameterSetResolver.new(example_parameters)

	assert_int(resolver.get_max_index()).is_equal(9)

	# We test here a parameter resolver for a test function signature like
	# `func test_foo(arg1, arg2, _test_parameters := [[a,b],[a,b]) -> void:`
	# The result of `get_parameters` must match the function signature
	# - first arg is extracted from the orignal _test_parameters array
	# - second arg is extracted from the orignal _test_parameters array
	# - third argument is a empty placeholder to replace the defaults of `_test_parameters` argument
	#   to avoid reinitalization of the complete parameter set

	var parameters := resolver.get_parameters(self, 0)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_instanceof(Node).is_valid()
	assert_object(parameters[1]).is_equal(Node)
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 1)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_instanceof(Node3D).is_valid()
	assert_object(parameters[1]).is_equal(Node3D)
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 2)
	assert_array(parameters).has_size(3)
	assert_str(parameters[0]).is_equal("abc")
	assert_str(parameters[1]).is_equal("String")
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 3)
	assert_array(parameters).has_size(3)
	assert_int(parameters[0]).is_equal(_x)
	assert_str(parameters[1]).is_equal("Integer")
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 4)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_equal(_obj).is_valid()
	assert_object(parameters[1]).is_equal(Node2D)
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 5)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_instanceof(TestObj).is_valid()
	assert_object(parameters[1]).is_equal(TestObj)
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 6)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_equal(Vector3(1,1,1))
	assert_object(parameters[1]).is_equal(Vector2(2,2))
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 7)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_equal(Color(1,1,1))
	assert_object(parameters[1]).is_equal(_color)
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 8)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_equal(_test_set_a[0])
	assert_object(parameters[1]).is_equal(_test_set_a[1])
	assert_object(parameters[2]).is_equal(_test_set_a[2])


func test_get_parameters_with_constants() -> void:
	var test_parameters := [
		'[Vector2.ONE, "Vector2"]',
		'[Vector3.ZERO, "Vector3"]',
		'[Color.RED, "Color"]',
	]

	var resolver := GdInlineParameterSetResolver.new(test_parameters)

	assert_int(resolver.get_max_index()).is_equal(3)

	var parameters := resolver.get_parameters(self, 0)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_equal(Vector2.ONE)
	assert_str(parameters[1]).is_equal("Vector2")
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 1)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_equal(Vector3.ZERO)
	assert_str(parameters[1]).is_equal("Vector3")
	assert_object(parameters[2]).is_equal([])

	parameters = resolver.get_parameters(self, 2)
	assert_array(parameters).has_size(3)
	assert_object(parameters[0]).is_equal(Color.RED)
	assert_str(parameters[1]).is_equal("Color")
	assert_object(parameters[2]).is_equal([])

#endregion


#region load_parameter_sets

func test_load_parameter_sets() -> void:
	assert_array(load_parameter_sets("test_example_a")) \
		.is_equal([[1, 2, []], [3, 4, []]])

	assert_array(load_parameter_sets("test_example_b")) \
		.is_equal([[Vector2.ZERO, Vector2.ONE, []], [Vector2(1.1, 3.2), Vector2.DOWN, []]])

	assert_array(load_parameter_sets("test_example_c")) \
		.is_equal([[Resource.new(), Resource.new(), []], [Resource.new(), null, []]])

	assert_array(load_parameter_sets("test_example_d")) \
		.is_equal([[Vector3(1, 1, 1), Vector3(3, 3, 3), []], [Vector3.BACK, Vector3.UP, []]])

	assert_array(load_parameter_sets("test_example_e")) \
		.is_equal([[TestObjNamed.new("abc"), TestObjNamed.new("def"), "abcdef", []]])


func test_load_parameter_sets_at_runtime() -> void:
	var params := load_parameter_sets("test_resolve_parameters_at_runtime")
	assert_that(params).is_not_null()
	assert_array(params) \
		.is_equal([
			# the value `_test_param1` is changed from 10 to 11 on `before` stage
			[1, 11, []],
			# the value `_test_param2` is changed from 20 to 22 on `test_before` stage
			[2, 22, []],
			# the value is static initial `30`
			[3, 30, []]])


func test_load_parameter_with_comments() -> void:
	var params := load_parameter_sets("test_parameterized_with_comments")
	assert_that(params).is_not_null()
	assert_array(params) \
		.is_equal([
			[1, 2, '3', 6, []],
			[3, 4, '5', 11, []],
			[6, 7, 'string #ABCD', 21, []],
			[6, 7, "string #ABCD", 21, []]])


func load_parameter_sets(child_name: String) -> Array[Array]:
	test_before()
	var script: GDScript = self.get_script()
	var function_descriptors := GdScriptParser.new().get_function_descriptors(script, [child_name])
	var fd: GdFunctionDescriptor = function_descriptors.front()
	var resolver := GdParameterSetResolverFactory.create(fd, self)
	if resolver == null:
		return []
	var result: Array[Array] = []
	for i in resolver.get_max_index():
		result.append(resolver.get_parameters(self, i))
	return result

#endregion


#region performance

func test_performance_single() -> void:
	const ITERATIONS := 1000
	var resolver := GdInlineParameterSetResolver.new(example_parameters)

	var t1 := Time.get_ticks_usec()
	for _i in ITERATIONS:
		resolver.get_parameters(self, 0)
	var elapsed_callable := Time.get_ticks_usec() - t1

	@warning_ignore_start("integer_division")
	prints("--- GdInlineParameterSetResolver:single performance (%d iterations) ---" % ITERATIONS)
	prints("	%8d µs  (%d µs/iteration)" % [elapsed_callable, elapsed_callable / ITERATIONS])
	@warning_ignore_restore("integer_division")


func test_performance_get_parameters_overall() -> void:
	const ITERATIONS := 1000
	var resolver := GdInlineParameterSetResolver.new(example_parameters)

	var t1 := Time.get_ticks_usec()
	for _i in ITERATIONS:
		for index in resolver.get_max_index():
			resolver.get_parameters(self, index)
	var elapsed_callable := Time.get_ticks_usec() - t1

	@warning_ignore_start("integer_division")
	prints("--- GdInlineParameterSetResolver:overall performance (%d iterations) ---" % ITERATIONS)
	prints("	%8d µs  (%d µs/iteration)" % [elapsed_callable, elapsed_callable / ITERATIONS])
	@warning_ignore_restore("integer_division")

#endregion
