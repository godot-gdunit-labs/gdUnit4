class_name GodotGdErrorMonitor
extends GdUnitMonitor


var _logger: GdUnitLogger


class GdUnitLogger extends Logger:
	var _entries: Array[ErrorLogEntry] = []
	var _is_report_push_errors: bool
	var _is_report_script_errors: bool


	func _init(is_report_push_errors: bool, is_report_script_errors: bool) -> void:
		_is_report_push_errors = is_report_push_errors
		_is_report_script_errors = is_report_script_errors
		OS.add_logger(self)


	func entries() -> Array[ErrorLogEntry]:
		return _entries

	func erase_log_entry(log_entry: ErrorLogEntry) -> void:
		for entry in _entries:
			if entry._type == log_entry._type and entry._message == log_entry._message:
				_entries.erase(entry)
				return


	func _log_error(
		_function: String,
		_file: String,
		_line: int,
		message: String,
		_rationale: String,
		_editor_notify: bool,
		error_type: int,
		script_backtraces: Array[ScriptBacktrace]
		) -> void:

		var stack_trace := _to_stack_trace(script_backtraces)

		match error_type:
			ErrorType.ERROR_TYPE_WARNING:
				if _is_report_push_errors:
					_entries.append(ErrorLogEntry.of_push_warning(stack_trace.get_line_number(), message, stack_trace))

			ErrorType.ERROR_TYPE_ERROR:
				if _is_report_push_errors:
					_entries.append(ErrorLogEntry.of_push_error(stack_trace.get_line_number(), message, stack_trace))

			ErrorType.ERROR_TYPE_SCRIPT:
				if _is_report_script_errors:
					_entries.append(ErrorLogEntry.of_script_error(stack_trace.get_line_number(), message, stack_trace))

			ErrorType.ERROR_TYPE_SHADER:
				pass
			_:
				prints("Unknwon log type", message)

	func _log_message(_message: String, _error: bool) -> void:
		pass


	func _to_stack_trace(script_backtraces: Array[ScriptBacktrace]) -> GdUnitStackTrace:
		var test_stack_trace: Array[GdUnitStackTraceElement] = []

		for sb in script_backtraces:
			for frame in sb.get_frame_count():
				var source := sb.get_frame_file(frame)

				if (source.begins_with("res://addons/gdUnit4/src/")
					or source.begins_with("user://tmp/mock/")
					or source.begins_with("user://tmp/spy/")):
					continue

				var function := sb.get_frame_function(frame)
				var line := sb.get_frame_line(frame)
				test_stack_trace.append(GdUnitStackTraceElement.new(source, line, function))
		return GdUnitStackTrace.of(test_stack_trace)


func _init() -> void:
	super("GdUnitLoggerMonitor")
	_logger = GdUnitLogger.new(GdUnitSettings.is_report_push_errors(), GdUnitSettings.is_report_script_errors())


func start() -> void:
	clear_logs()


func stop() -> void:
	pass


func log_entries() -> Array[ErrorLogEntry]:
	return _logger.entries()


func erase_log_entry(log_entry: ErrorLogEntry) -> void:
	_logger.erase_log_entry(log_entry)


func to_reports() -> Array[GdUnitReport]:
	var reports_: Array[GdUnitReport] = []

	reports_.assign(log_entries().map(_to_report))

	return reports_


static func _to_report(errorLog: ErrorLogEntry) -> GdUnitReport:

	var failure := """
		%s
		  %s""".dedent().trim_prefix("\n") % [
		GdAssertMessages._error("Godot Runtime Error !"),
		GdAssertMessages._colored_value(errorLog._message)]
	var error := GdUnitError.new(failure, errorLog._line, errorLog._stack_trace)
	return GdUnitReport.new().from_error(GdUnitReport.ABORT, error)


func clear_logs() -> void:
	log_entries().clear()
