# GdUnit generated TestSuite
class_name EqualsArgumentMatcherTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit4/src/matchers/EqualsArgumentMatcher.gd'


func test_is_match() -> void:
	var matcher := EqualsArgumentMatcher.new("foo")

	assert_bool(matcher.is_match("foo")).is_true()
	assert_bool(matcher.is_match("bar")).is_false()


func test_is_match_string_is_case_sensitive() -> void:
	var matcher := EqualsArgumentMatcher.new("Foo")

	assert_bool(matcher.is_match("Foo")).is_true()
	assert_bool(matcher.is_match("foo")).is_false()
