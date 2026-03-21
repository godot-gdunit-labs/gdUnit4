# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GodotGdErrorMonitorTest
extends GdUnitTestSuite


var _save_is_report_push_errors :bool
var _save_is_report_script_errors :bool


func before() -> void:
	_save_is_report_push_errors = GdUnitSettings.is_report_push_errors()
	_save_is_report_script_errors = GdUnitSettings.is_report_script_errors()
	# disable default error reporting for testing
	ProjectSettings.set_setting(GdUnitSettings.REPORT_PUSH_ERRORS, false)
	ProjectSettings.set_setting(GdUnitSettings.REPORT_SCRIPT_ERRORS, false)


func after() -> void:
	ProjectSettings.set_setting(GdUnitSettings.REPORT_PUSH_ERRORS, _save_is_report_push_errors)
	ProjectSettings.set_setting(GdUnitSettings.REPORT_SCRIPT_ERRORS, _save_is_report_script_errors)


func test_monitor_push_error() -> void:
	var monitor := GodotGdErrorMonitor.new()
	monitor._logger._is_report_push_errors = true
	# no errors reported
	monitor.start()
	monitor.stop()
	assert_array(monitor.to_reports()).is_empty()

	# push error
	monitor.start()
	forcet_push_error()
	monitor.stop()

	var reports := monitor.to_reports()
	assert_array(reports).has_size(1)
	prints(reports[0].message())
	assert_str(reports[0].message())\
		.contains("Test GodotGdErrorMonitor 'push_error' reporting")\
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:78")\
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:73")\
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:35")
	assert_int(reports[0].line_number()).is_equal(35)


func test_monitor_push_waring() -> void:
	var monitor := GodotGdErrorMonitor.new()
	monitor._logger._is_report_push_errors = true

	# push error
	monitor.start()
	push_warning("Test GodotGdErrorMonitor 'push_warning' reporting")
	monitor.stop()

	var reports := monitor.to_reports()
	assert_array(reports).has_size(1)
	assert_str(reports[0].message())\
		.contains("Test GodotGdErrorMonitor 'push_warning' reporting")\
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:55")
	assert_int(reports[0].line_number()).is_equal(55)


func test_fail_by_push_error(_do_skip := true, _skip_reason := "disabled to not produce errors, enable only for direct testing") -> void:
	GdUnitThreadManager.get_current_context().get_execution_context().error_monitor._logger._is_report_push_errors = true
	push_error("test error")


func forcet_push_error() -> void:
	@warning_ignore("redundant_await")
	await forcet_push_error2()


func forcet_push_error2() -> void:
	#await get_tree().process_frame
	push_error("Test GodotGdErrorMonitor 'push_error' reporting")
