class_name GeneratedPersonTest
extends GdUnitTestSuite


func test_name() -> void:
	assert_that(Person.new().name()).is_equal("Hoschi")
