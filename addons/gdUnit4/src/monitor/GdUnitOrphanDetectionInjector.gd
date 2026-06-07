## Patches GDScript test suite source code to inject orphan node detection calls
## at the end of each test_ function, eliminating the need for manual calls.
class_name GdUnitOrphanDetectionInjector
extends RefCounted


## The code block injected at the end of each test_ function body.
const INJECT_CODE := "\n"\
	+ "	# Injected collect orphan details\n" \
	+ "	await get_tree().process_frame\n" \
	+ "	collect_orphan_node_details()"

## Number of lines INJECT_CODE adds per injection; used to compute and undo line shifts.
static var _injection_line_count := INJECT_CODE.split("\n").size()

## Maps resource_path -> sorted Array[int] of patched line indices where each injection block starts.
## Used by resolve_original_line to map patched line numbers back to original source line numbers.
static var _injection_positions: Dictionary[String, Array] = {}


## Patches the given GDScript by injecting orphan detection calls at the end of each test_ function.
static func intercept(script: GDScript, function_descriptors: Array[GdFunctionDescriptor] = []) -> void:
	if function_descriptors.is_empty():
		return

	var source := GdScriptParser.to_unix_format(script.source_code)
	var positions: Array[int] = []
	var patched := _inject_from_descriptors(source, function_descriptors, positions)
	if patched == source:
		return

	_injection_positions[script.resource_path] = positions
	script.source_code = patched
	script.reload()


## Clears all recorded injection positions; call after a test suite finishes.
static func cleanup() -> void:
	_injection_positions.clear()


## Converts a patched source line number back to the original source line number.
## Returns patched_line unchanged when the script was not intercepted.
static func resolve_original_line(resource_path: String, patched_line: int) -> int:
	if not _injection_positions.has(resource_path):
		return patched_line

	return _resolve_line(_injection_positions[resource_path], patched_line)


## Injects INJECT_CODE after each test_ function body and records the patched line indices
## of each injection start into injection_positions.
static func _inject_from_descriptors(
	source: String,
	function_descriptors: Array[GdFunctionDescriptor],
	injection_positions: Array[int] = []
) -> String:
	if function_descriptors.is_empty():
		return source

	# Sort descending so functions are processed bottom-to-top.
	# Each insert() shifts all following line indices; starting from the end of the file
	# ensures that earlier functions' end_line values remain valid when we reach them.
	function_descriptors.sort_custom(func(a: GdFunctionDescriptor, b: GdFunctionDescriptor) -> bool:
		return a.end_line() > b.end_line()
	)
	var lines := Array(source.split("\n"))
	var end_lines: Array[int] = []
	for fd: GdFunctionDescriptor in function_descriptors:
		var func_lines := PackedStringArray(lines.slice(fd.begin_line(), fd.end_line()))
		if _has_orphan_collect_call(func_lines):
			continue
		lines.insert(fd.end_line(), INJECT_CODE)
		end_lines.append(fd.end_line())
	if end_lines.is_empty():
		return source
	end_lines.sort()
	for i: int in end_lines.size():
		injection_positions.append(end_lines[i] + 1 + i * _injection_line_count)
	return "\n".join(lines)


## Subtracts the cumulative injection offset from patched_line to recover the original line index.
static func _resolve_line(positions: Array[int], patched_line: int) -> int:
	var offset := 0
	for pos in positions:
		if pos <= patched_line:
			offset += _injection_line_count
		else:
			break
	return patched_line - offset


## Returns true when func_lines already contains a collect_orphan_node_details call.
static func _has_orphan_collect_call(func_lines: PackedStringArray) -> bool:
	for line: String in func_lines:
		if line.contains("collect_orphan_node_details"):
			return true
	return false
