# GdUnit generated TestSuite
class_name GdUnitHtmlPatternsTest
extends GdUnitTestSuite


func _make_suite_report(resource_path: String, suite_name: String) -> GdUnitTestSuiteReport:
	return GdUnitTestSuiteReport.new(resource_path, suite_name, 1, func(s: String) -> String: return s)


#region create_suite_record
func test_href_is_quoted() -> void:
	var report := _make_suite_report("res://test/game_test.gd", "game_test")
	var html := GdUnitHtmlPatterns.create_suite_record("./test_suites/game_test.html", report)
	assert_str(html).contains('href="./test_suites/game_test.html"')


func test_href_is_quoted_when_link_contains_spaces() -> void:
	var report := _make_suite_report("res://my test/game_test.gd", "game_test")
	var link := "./test_suites/my_test.game_test.html"
	var html := GdUnitHtmlPatterns.create_suite_record(link, report)
	assert_str(html).contains('href="%s"' % link)


func test_href_is_not_unquoted() -> void:
	var report := _make_suite_report("res://my test/game_test.gd", "game_test")
	var link := "./test_suites/my_test.game_test.html"
	var html := GdUnitHtmlPatterns.create_suite_record(link, report)
	assert_str(html).not_contains("href=%s" % link)
#endregion


#region get_path_as_link
func test_get_path_as_link_simple() -> void:
	var report := _make_suite_report("res://test/suite/game_test.gd", "game_test")
	assert_str(GdUnitHtmlPatterns.get_path_as_link(report)).is_equal("../path/test.suite.html")


func test_get_path_as_link_converts_slashes_to_dots() -> void:
	var report := _make_suite_report("res://a/b/c/game_test.gd", "game_test")
	assert_str(GdUnitHtmlPatterns.get_path_as_link(report)).is_equal("../path/a.b.c.html")
#endregion
