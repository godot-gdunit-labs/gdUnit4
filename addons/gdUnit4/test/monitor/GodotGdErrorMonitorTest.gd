# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GodotGdErrorMonitorTest
extends GdUnitTestSuite


func before() -> void:
	# disable default error reporting for testing
	ProjectSettings.set_setting(GdUnitSettings.REPORT_PUSH_ERRORS, false)
	ProjectSettings.set_setting(GdUnitSettings.REPORT_SCRIPT_ERRORS, false)


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
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:67")\
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:62")\
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:24")
	assert_int(reports[0].line_number()).is_equal(24)


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
		.contains("at res://addons/gdUnit4/test/monitor/GodotGdErrorMonitorTest.gd:44")
	assert_int(reports[0].line_number()).is_equal(44)


func test_fail_by_push_error(_do_skip := true, _skip_reason := "disabled to not produce errors, enable only for direct testing") -> void:
	GdUnitThreadManager.get_current_context().get_execution_context().error_monitor._logger._is_report_push_errors = true
	push_error("test error")


func forcet_push_error() -> void:
	@warning_ignore("redundant_await")
	await forcet_push_error2()


func forcet_push_error2() -> void:
	#await get_tree().process_frame
	push_error("Test GodotGdErrorMonitor 'push_error' reporting")
