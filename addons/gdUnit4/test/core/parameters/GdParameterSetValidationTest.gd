extends GdUnitTestSuite


const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")


func test_validate_parameter_set() -> void:
	var test_suite: GdUnitTestSuite = auto_free(
		GdUnitTestResourceLoader.load_test_suite(
			"res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteInvalidParameterizedTests.gd"
		)
	)

	assert_is_not_skipped(test_suite, "test_no_parameters")
	assert_is_not_skipped(test_suite, "test_parameterized_success", 0)
	assert_is_not_skipped(test_suite, "test_parameterized_success", 1)
	assert_is_not_skipped(test_suite, "test_parameterized_success", 2)
	assert_is_not_skipped(test_suite, "test_parameterized_failed", 0)
	assert_is_not_skipped(test_suite, "test_parameterized_failed", 1)
	assert_is_not_skipped(test_suite, "test_parameterized_failed", 2)
	assert_is_skipped(test_suite, "test_parameterized_to_less_args", 0).is_equal(
		"""
			The test data set at index (0) does not match the expected test arguments:
				test function: func test...(a: int,b: int,expected: int)
				test input values: [1, 2, 3, 6]
		""".dedent()
	)
	assert_is_skipped(test_suite, "test_parameterized_to_less_args", 1).is_equal(
		"""
			The test data set at index (1) does not match the expected test arguments:
				test function: func test...(a: int,b: int,expected: int)
				test input values: [3, 4, 5, 11]
		""".dedent()
	)
	assert_is_skipped(test_suite, "test_parameterized_to_many_args", 0).is_equal(
		"""
			The test data set at index (0) does not match the expected test arguments:
				test function: func test...(a: int,b: int,c: int,d: int,expected: int)
				test input values: [1, 2, 3, 6]
		""".dedent()
	)
	# test_parameterized_invalid_struct
	assert_is_not_skipped(test_suite, "test_parameterized_invalid_struct", 0)
	assert_is_skipped(test_suite, "test_parameterized_invalid_struct", 1).is_equal(
		"""
			The test data set at index (1) does not match the expected test arguments:
				test function: func test...(a: int,b: int,expected: int)
				test input values: ["foo"]
		""".dedent()
	)
	assert_is_not_skipped(test_suite, "test_parameterized_invalid_struct", 2)
	# test_parameterized_invalid_args
	assert_is_not_skipped(test_suite, "test_parameterized_invalid_args", 0)
	assert_is_skipped(test_suite, "test_parameterized_invalid_args", 1).is_equal(
		"""
			The test data value does not match the expected input type!
				input value: '4', <String>
				expected argument: b: int
		""".dedent()
	)
	assert_is_not_skipped(test_suite, "test_parameterized_invalid_args", 2)


func assert_is_not_skipped(test_suite: GdUnitTestSuite, test_case: String, index := -1) -> void:
	var test := simulate_test_execution_with_parameter_validation(test_suite, test_case, index)
	assert_bool(test.is_skipped()).is_false()


func assert_is_skipped(test_suite: GdUnitTestSuite, test_case: String, index := -1) -> GdUnitStringAssert:
	var test := simulate_test_execution_with_parameter_validation(test_suite, test_case, index)
	assert_bool(test.is_skipped()).is_true()
	return assert_str(GdUnitTools.richtext_normalize(test.skip_info()))


## Simulates _TestCase:execute_parameterized with parameter validation
func simulate_test_execution_with_parameter_validation(test_suite: GdUnitTestSuite, test_case_name: String, index := -1) -> _TestCase:
	var test: _TestCase = GdUnitTools.find_test_case(test_suite, test_case_name, index)
	if test == null or not test.is_parameterized():
		return test
	var attribute_index := test._test_case.attribute_index
	var script: GDScript = test_suite.get_script()
	var fds := GdScriptParser.new().get_function_descriptors(script, [test_case_name])
	if fds.is_empty():
		return test
	var fd: GdFunctionDescriptor = fds.front()
	var resolver := GdParameterSetResolverFactory.create(fd, test_suite)
	if resolver == null:
		return test
	var parameter_set := resolver.get_parameters(test_suite, attribute_index)
	var result := _validate_parameter_set(fd, parameter_set, attribute_index)
	if result.is_error():
		test.do_skip(true, result.error_message())
	return test


static func _validate_parameter_set(fd: GdFunctionDescriptor, parameter_set: Array, parameter_set_index: int) -> GdUnitResult:
	var input_arguments := fd.args()
	var expected_arg_count := input_arguments.size()
	var current_arg_count := parameter_set.size()
	if current_arg_count != expected_arg_count:
		var arg_names := input_arguments \
			.filter(func(arg: GdFunctionArgument) -> bool: return not arg.is_parameter_set()) \
			.map(func(arg: GdFunctionArgument) -> String: return str(arg))
		var test_parameters := parameter_set.slice(0, parameter_set.size() - 1)
		return GdUnitResult.error("""
			The test data set at index (%d) does not match the expected test arguments:
				test function: [color=snow]func test...(%s)[/color]
				test input values: [color=snow]%s[/color]
			""".dedent() % [parameter_set_index, ",".join(arg_names), test_parameters])
	return GdUnitTestParameterSetResolver.validate_parameter_types(input_arguments, parameter_set)
