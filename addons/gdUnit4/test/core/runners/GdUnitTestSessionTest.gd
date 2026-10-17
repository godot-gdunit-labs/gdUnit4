class_name GdUnitTestSessionTest
extends GdUnitTestSuite


#region find_test_by_id
func test_find_test_by_id() -> void:
	var test_cases := _test_cases()
	var session := GdUnitTestSession.new(test_cases, "res://reports")

	assert_that(session.find_test_by_id(test_cases[0].guid)).is_same(test_cases[0])
	assert_that(session.find_test_by_id(test_cases[1].guid)).is_same(test_cases[1])


func test_find_test_by_id_with_equal_guid() -> void:
	var test_cases := _test_cases()
	var session := GdUnitTestSession.new(test_cases, "res://reports")

	assert_that(session.find_test_by_id(GdUnitGUID.new(str(test_cases[1].guid)))).is_same(test_cases[1])


func test_find_test_by_id_not_found() -> void:
	var session := GdUnitTestSession.new(_test_cases(), "res://reports")

	assert_object(session.find_test_by_id(GdUnitGUID.new())).is_null()
#endregion


#region documented examples
# The following tests verify the examples of the migration guide page
# documentation/doc/_first_steps/migration-v7.md


func test_doc_migration_test_cases_by_id_example() -> void:
	var session := GdUnitTestSession.new(_test_cases(), "res://reports")

	var test_count := session._test_cases_by_id.size()

	assert_int(test_count).is_equal(2)
#endregion


func _test_cases() -> Array[GdUnitTestCase]:
	var test_cases: Array[GdUnitTestCase] = [
		GdUnitTestCase.from("res://test/example_suite.gd", "res://test/example_suite.gd", 10, "test_a"),
		GdUnitTestCase.from("res://test/example_suite.gd", "res://test/example_suite.gd", 14, "test_b"),
	]
	return test_cases
