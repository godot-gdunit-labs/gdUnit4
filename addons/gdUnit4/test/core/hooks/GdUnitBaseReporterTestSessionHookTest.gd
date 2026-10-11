extends GdUnitTestSuite


const __source = "res://addons/gdUnit4/src/core/hooks/GdUnitBaseReporterTestSessionHook.gd"


class FakeReportWriter extends GdUnitReportWriter:

	func write(_report_path: String, _report: GdUnitReportSummary) -> String:
		return "C:/reports/report_1/index.html"

	func output_format() -> String:
		return "HTML"


func test_shutdown_sends_report_path_as_file_uri() -> void:
	var hook := GdUnitBaseReporterTestSessionHook.new(FakeReportWriter.new(), "FakeReporter", "", Callable())
	var messages: Array[String] = []
	var collect_message := func(message: String) -> void:
		messages.append(message)
	GdUnitSignals.instance().gdunit_message.connect(collect_message)

	hook.shutdown(GdUnitTestSession.new([], "res://reports"))
	GdUnitSignals.instance().gdunit_message.disconnect(collect_message)

	assert_array(messages).contains_exactly(["Open HTML Report at: file:///C:/reports/report_1/index.html"])
