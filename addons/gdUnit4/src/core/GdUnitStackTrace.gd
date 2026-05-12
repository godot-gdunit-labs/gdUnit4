## Captures and holds the test-side call stack at the point of an assertion failure.[br]
## Internal gdUnit4 frames are filtered out, leaving only user and test script frames.
class_name GdUnitStackTrace
extends RefCounted

var _stack_trace: Array[GdUnitStackTraceElement]


func _init(stack_trace := _extract_test_stack_trace()) -> void:
	_stack_trace = stack_trace


## Returns a newline-separated string of all frames in the stack trace.
func _to_string() -> String:
	return "\n".join(_stack_trace)


## Returns all frames in the stack trace, ordered innermost first.
func get_frames() -> Array[GdUnitStackTraceElement]:
	return _stack_trace


## Returns the line number of the topmost frame, or [code]-1[/code] if the stack trace is empty.
func get_line_number() -> int:
	if _stack_trace.is_empty():
		return -1
	return _stack_trace.front()._line


## Returns a formatted multi-line string with each frame listed as [code]at - source:line in function 'name'[/code].
func print_stack_trace() -> String:
	var output := ""
	for frame in _stack_trace:
		output += "\tat - %s:%d in function '%s'\n" % [frame._source, frame._line, frame._function]
	return output


## Serializes the stack trace to a JSON string.
func serialize() -> String:
	var frames: Array[Dictionary] = []
	for frame in _stack_trace:
		frames.append({"source": frame._source, "line": frame._line, "function": frame._function})
	return JSON.stringify(frames)


## Reconstructs a [GdUnitStackTrace] from a JSON string produced by [method serialize].
static func deserialize(json: String) -> GdUnitStackTrace:
	var data: Variant = JSON.parse_string(json)
	if not data is Array:
		return GdUnitStackTrace.of([])
	var frames: Array[GdUnitStackTraceElement] = []
	for frame_data: Dictionary in data:
		frames.append(GdUnitStackTraceElement.of(frame_data))
	return GdUnitStackTrace.of(frames)


## Creates a [GdUnitStackTrace] from an existing array of [GdUnitStackTraceElement] frames.[br]
## Useful for constructing expected stack traces in assertions.
static func of(stack_trace: Array[GdUnitStackTraceElement]) -> GdUnitStackTrace:
	return GdUnitStackTrace.new(stack_trace)


## Captures the current GDScript call stack and filters out all internal gdUnit4 frames,[br]
## returning only frames from user scripts and test files.
static func _extract_test_stack_trace() -> Array[GdUnitStackTraceElement]:
	var stack_trace: Array[Dictionary] = get_stack()
	if stack_trace == null or stack_trace.is_empty():
		return []

	var test_stack_trace: Array[GdUnitStackTraceElement] = []
	for index in range(stack_trace.size() - 1, -1, -1):
		var stack_info := stack_trace[index]
		var source: String = stack_info.get("source")

		if (source.begins_with("res://addons/gdUnit4/src/")
			or source.begins_with("user://tmp/mock/")
			or source.begins_with("user://tmp/spy/")):
			continue

		var line: int = stack_info.get("line")
		var function: String = stack_info.get("function")

		test_stack_trace.append(GdUnitStackTraceElement.new(source, line, function))

	test_stack_trace.reverse()
	return test_stack_trace
