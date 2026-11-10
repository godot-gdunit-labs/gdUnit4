# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdUnitTestResourceLoaderTest
extends GdUnitTestSuite


func test_load_test_suite_gd() -> void:
	var resource_path := "res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteParameterizedTests.gd"
	var test_suite := GdUnitTestResourceLoader.load_test_suite_gd(resource_path)
	assert_that(test_suite).is_not_null()
	assert_object(test_suite).is_instanceof(GdUnitTestSuite)
	test_suite.free()


func test_load_tests() -> void:
	var tests := GdUnitTestResourceLoader.load_tests("res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteAllStagesSuccess.gd")

	assert_array(tests.keys()).contains_exactly_in_any_order(["test_case1", "test_case2"])
