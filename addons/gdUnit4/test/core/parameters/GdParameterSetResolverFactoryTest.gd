extends GdUnitTestSuite

var _test_properties := [
	["test_a"],
	["test_b"],
	["test_c"]
]


func _static_parameters(_a: int, _b: int, _test_parameters := [[1, 2], [3, 4]]) -> void:
	pass


func _callable_parameters(_a: int, _b: int, _test_parameters := _build_params()) -> void:
	pass


func _properties_parameters(_a: int, _b: int, _test_parameters := _test_properties) -> void:
	pass


func _no_parameters(_a: int, _b: int) -> void:
	pass


func _build_params() -> Array[Array]:
	return [[1, 2], [3, 4]]


func _descriptor(func_name: String) -> GdFunctionDescriptor:
	var script: GDScript = get_script()
	return GdScriptParser.new().get_function_descriptors(script, [func_name]).front()


#region get_class_type_mapping

func test_get_class_type_mapping() -> void:
	var expected_count := 0
	for clazz_name in ClassDB.get_class_list():
		if ClassDB.class_get_api_type(clazz_name) != 0 or not ClassDB.can_instantiate(clazz_name):
			continue
		expected_count += 1

	assert_dict(GdParameterSetResolverFactory.get_class_type_mapping()).has_size(expected_count)
	# Second call returns the same cached mapping without rebuilding
	assert_dict(GdParameterSetResolverFactory.get_class_type_mapping()).has_size(expected_count)

#endregion


#region create

func test_create_returns_null_for_non_parameterized() -> void:
	var resolver := GdParameterSetResolverFactory.create(_descriptor("_no_parameters"), self)
	assert_that(resolver).is_null()


func test_create_returns_inline_resolver() -> void:
	var resolver := GdParameterSetResolverFactory.create(_descriptor("_static_parameters"), self)
	assert_object(resolver).is_instanceof(GdInlineParameterSetResolver)
	assert_int(resolver.get_max_index()).is_equal(2)


func test_create_returns_callable_resolver() -> void:
	var resolver := GdParameterSetResolverFactory.create(_descriptor("_callable_parameters"), self)
	assert_object(resolver).is_instanceof(GdCallableParameterSetResolver)
	assert_int(resolver.get_max_index()).is_equal(2)


func test_create_returns_property_resolver() -> void:
	var resolver := GdParameterSetResolverFactory.create(_descriptor("_properties_parameters"), self)
	assert_object(resolver).is_instanceof(GdPropertyParameterSetResolver)
	assert_int(resolver.get_max_index()).is_equal(3)

#endregion
