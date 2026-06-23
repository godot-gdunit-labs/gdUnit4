class_name GdFunctionArgument
extends RefCounted


const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")
const UNDEFINED: String = "<-NO_ARG->"
const ARG_PARAMETERIZED_TEST := ["test_parameters", "_test_parameters"]

static var _fuzzer_regex: RegEx
static var _cleanup_leading_spaces := RegEx.create_from_string("(?m)^[ \t]+")
static var _fix_comma_space := RegEx.create_from_string(""", {0,}\t{0,}(?=(?:[^"]*"[^"]*")*[^"]*$)(?!\\s)""")
static var _char_lut: PackedByteArray

var _name: String
var _type: int
var _type_hint: int
var _default_value: Variant
var _parameter_sets: PackedStringArray = []


func _init(p_name: String, p_type: int, value: Variant = UNDEFINED, p_type_hint: int = TYPE_NIL) -> void:
	_init_static_variables()
	_name = p_name
	_type = p_type
	_type_hint = p_type_hint
	if value != null and p_name in ARG_PARAMETERIZED_TEST:
		_parameter_sets = _parse_parameter_set_v3(str(value))
	_default_value = value
	# is argument a fuzzer?
	if _type == TYPE_OBJECT and _fuzzer_regex.search(_name):
		_type = GdObjects.TYPE_FUZZER


func _init_static_variables() -> void:
	if _fuzzer_regex == null:
		_fuzzer_regex = GdUnitTools.to_regex("((?!(fuzzer_(seed|iterations)))fuzzer?\\w+)( ?+= ?+| ?+:= ?+| ?+:Fuzzer ?+= ?+|)")
		_cleanup_leading_spaces = RegEx.create_from_string("(?m)^[ \t]+")
		_fix_comma_space = RegEx.create_from_string(""", {0,}\t{0,}(?=(?:[^"]*"[^"]*")*[^"]*$)(?!\\s)""")


func name() -> String:
	return _name


func default() -> Variant:
	return type_convert(_default_value, _type)


func set_value(value: String) -> void:
	# we onle need to apply default values for Objects, all others are provided by the method descriptor
	if _type == GdObjects.TYPE_FUZZER:
		_default_value = value
		return
	if _name in ARG_PARAMETERIZED_TEST:
		_parameter_sets = _parse_parameter_set(value)
		_default_value = value
		return

	if _type == TYPE_NIL or _type == GdObjects.TYPE_VARIANT:
		_type = _extract_value_type(value)
		if _type == GdObjects.TYPE_VARIANT and _default_value == null:
			_default_value = value
	if _default_value == null:
		match _type:
			TYPE_DICTIONARY:
				_default_value = as_dictionary(value)
			TYPE_ARRAY:
				_default_value = as_array(value)
			GdObjects.TYPE_FUZZER:
				_default_value = value
			_:
				_default_value = str_to_var(value)
				# if converting fails assign the original value without converting
				if _default_value == null and value != null:
					_default_value = value
		#prints("set default_value: ", _default_value, "with type %d" % _type, " from original: '%s'" % value)


func _extract_value_type(value: String) -> int:
	if value != UNDEFINED:
		if _fuzzer_regex.search(_name):
			return GdObjects.TYPE_FUZZER
		if value.rfind(")") == value.length()-1:
			return GdObjects.TYPE_FUNC
	return _type


func value_as_string() -> String:
	if has_default():
		return GdDefaultValueDecoder.decode_typed(_type, _default_value)
	return ""


func plain_value() -> Variant:
	return _default_value


func type() -> int:
	return _type


func type_hint() -> int:
	return _type_hint


func has_default() -> bool:
	return not is_same(_default_value, UNDEFINED)


func is_typed_array() -> bool:
	return _type == TYPE_ARRAY and _type_hint != TYPE_NIL


func is_parameter_set() -> bool:
	return _name in ARG_PARAMETERIZED_TEST


func parameter_sets() -> PackedStringArray:
	return _parameter_sets


static func get_parameter_set(parameters: Array[GdFunctionArgument]) -> GdFunctionArgument:
	for current in parameters:
		if current != null and current.is_parameter_set():
			return current
	return null


func _to_string() -> String:
	var s := _name
	if _type != TYPE_NIL:
		s += ": " + GdObjects.type_as_string(_type)
	if _type_hint != TYPE_NIL:
		s += "[%s]" % GdObjects.type_as_string(_type_hint)
	if has_default():
		s += "=" + value_as_string()
	return s


static func _parse_parameter_set(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []

	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var single_quote := false
	var double_quote := false
	var array_end := 0
	var current_index := 0
	var output :PackedStringArray = []
	var buf := input.to_utf8_buffer()
	var collected_characters: = PackedByteArray()
	var matched :bool = false

	for c in buf:
		current_index += 1
		matched = current_index == buf.size()
		@warning_ignore("return_value_discarded")
		collected_characters.push_back(c)

		match c:
			# ' ': ignore spaces between array elements
			32: if array_end == 0 and (not double_quote and not single_quote):
					collected_characters.remove_at(collected_characters.size()-1)
			# '\n': strip newlines outside quoted strings, preserve inside
			10: if not double_quote and not single_quote:
					collected_characters.remove_at(collected_characters.size()-1)
			# ',': step over array element seperator ','
			44: if array_end == 0:
					matched = true
					collected_characters.remove_at(collected_characters.size()-1)
			# '`':
			39: single_quote = !single_quote
			# '"':
			34: if not single_quote: double_quote = !double_quote
			# '['
			91: if not double_quote and not single_quote: array_end +=1 # counts array open
			# ']'
			93: if not double_quote and not single_quote: array_end -=1 # counts array closed

		# if array closed than collect the element
		if matched:
			var parameters := _fix_comma_space.sub(collected_characters.get_string_from_utf8(), ", ", true)
			if not parameters.is_empty():
				@warning_ignore("return_value_discarded")
				output.append(parameters)
			collected_characters.clear()
			matched = false
	return output


static func _parse_parameter_set_v2(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []

	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")

	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	var buf_size := buf.size()
	if buf_size == 0:
		return output

	# Pre-allocated write-buffer avoids push_back/remove_at per byte
	var work := PackedByteArray()
	work.resize(buf_size)
	var wp := 0
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	# Pending comma: skip trailing whitespace, then insert one space before the next token
	var after_comma := false

	for c: int in buf:
		var in_string: bool = single_quote or double_quote
		match c:
			32:  # ' '
				if in_string:
					work[wp] = c; wp += 1; after_comma = false
				elif array_depth > 0 and not after_comma:
					work[wp] = c; wp += 1
			10:  # '\n'
				if in_string:
					work[wp] = c; wp += 1
			44:  # ','
				if array_depth == 0:
					if wp > 0:
						@warning_ignore("return_value_discarded")
						output.append(work.slice(0, wp).get_string_from_utf8())
						wp = 0
					after_comma = false
				else:
					work[wp] = c; wp += 1
					if not in_string:
						after_comma = true
			39:  # '\''
				single_quote = not single_quote
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			34:  # '"'
				if not single_quote:
					double_quote = not double_quote
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			91:  # '['
				if not in_string:
					array_depth += 1
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			93:  # ']'
				if not in_string:
					array_depth -= 1
				after_comma = false
				work[wp] = c; wp += 1
			_:
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1

	if wp > 0:
		@warning_ignore("return_value_discarded")
		output.append(work.slice(0, wp).get_string_from_utf8())
	return output


## v3 — same algorithm as v2 but with if/elif chain instead of match
static func _parse_parameter_set_v3(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	var buf_size := buf.size()
	if buf_size == 0:
		return output
	var work := PackedByteArray()
	work.resize(buf_size)
	var wp := 0
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	var after_comma := false
	for c: int in buf:
		var in_string: bool = single_quote or double_quote
		if c == 32:
			if in_string:
				work[wp] = c; wp += 1; after_comma = false
			elif array_depth > 0 and not after_comma:
				work[wp] = c; wp += 1
		elif c == 10:
			if in_string:
				work[wp] = c; wp += 1
		elif c == 44:
			if array_depth == 0:
				if wp > 0:
					@warning_ignore("return_value_discarded")
					output.append(work.slice(0, wp).get_string_from_utf8())
					wp = 0
				after_comma = false
			else:
				work[wp] = c; wp += 1
				if not in_string:
					after_comma = true
		elif c == 39:
			single_quote = not single_quote
			if after_comma:
				work[wp] = 32; wp += 1; after_comma = false
			work[wp] = c; wp += 1
		elif c == 34:
			if not single_quote:
				double_quote = not double_quote
			if after_comma:
				work[wp] = 32; wp += 1; after_comma = false
			work[wp] = c; wp += 1
		elif c == 91:
			if not in_string:
				array_depth += 1
			if after_comma:
				work[wp] = 32; wp += 1; after_comma = false
			work[wp] = c; wp += 1
		elif c == 93:
			if not in_string:
				array_depth -= 1
			after_comma = false
			work[wp] = c; wp += 1
		else:
			if after_comma:
				work[wp] = 32; wp += 1; after_comma = false
			work[wp] = c; wp += 1
	if wp > 0:
		@warning_ignore("return_value_discarded")
		output.append(work.slice(0, wp).get_string_from_utf8())
	return output


## v4 — String += char(c) accumulator; no byte buffer
static func _parse_parameter_set_v4(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	var after_comma := false
	var element := ""
	for c: int in buf:
		var in_string: bool = single_quote or double_quote
		match c:
			32:
				if in_string:
					element += char(c); after_comma = false
				elif array_depth > 0 and not after_comma:
					element += char(c)
			10:
				if in_string:
					element += char(c)
			44:
				if array_depth == 0:
					if not element.is_empty():
						@warning_ignore("return_value_discarded")
						output.append(element)
						element = ""
					after_comma = false
				else:
					element += char(c)
					if not in_string:
						after_comma = true
			39:
				single_quote = not single_quote
				if after_comma:
					element += " "; after_comma = false
				element += char(c)
			34:
				if not single_quote:
					double_quote = not double_quote
				if after_comma:
					element += " "; after_comma = false
				element += char(c)
			91:
				if not in_string:
					array_depth += 1
				if after_comma:
					element += " "; after_comma = false
				element += char(c)
			93:
				if not in_string:
					array_depth -= 1
				after_comma = false
				element += char(c)
			_:
				if after_comma:
					element += " "; after_comma = false
				element += char(c)
	if not element.is_empty():
		@warning_ignore("return_value_discarded")
		output.append(element)
	return output


## v5 — unicode_at(i) loop avoids to_utf8_buffer() allocation; pre-alloc PAB write pointer
static func _parse_parameter_set_v5(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var length := input.length()
	if length == 0:
		return output
	var work := PackedByteArray()
	work.resize(length)
	var wp := 0
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	var after_comma := false
	for i in length:
		var c: int = input.unicode_at(i)
		var in_string: bool = single_quote or double_quote
		match c:
			32:
				if in_string:
					work[wp] = c; wp += 1; after_comma = false
				elif array_depth > 0 and not after_comma:
					work[wp] = c; wp += 1
			10:
				if in_string:
					work[wp] = c; wp += 1
			44:
				if array_depth == 0:
					if wp > 0:
						@warning_ignore("return_value_discarded")
						output.append(work.slice(0, wp).get_string_from_utf8())
						wp = 0
					after_comma = false
				else:
					work[wp] = c; wp += 1
					if not in_string:
						after_comma = true
			39:
				single_quote = not single_quote
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			34:
				if not single_quote:
					double_quote = not double_quote
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			91:
				if not in_string:
					array_depth += 1
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			93:
				if not in_string:
					array_depth -= 1
				after_comma = false
				work[wp] = c; wp += 1
			_:
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
	if wp > 0:
		@warning_ignore("return_value_discarded")
		output.append(work.slice(0, wp).get_string_from_utf8())
	return output


## v6 — input[i] String indexing + String concatenation; no byte buffers at all
static func _parse_parameter_set_v6(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var length := input.length()
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	var after_comma := false
	var element := ""
	for i in length:
		var c: int = input.unicode_at(i)
		var ch: String = input[i]
		var in_string: bool = single_quote or double_quote
		match c:
			32:
				if in_string:
					element += ch; after_comma = false
				elif array_depth > 0 and not after_comma:
					element += ch
			10:
				if in_string:
					element += ch
			44:
				if array_depth == 0:
					if not element.is_empty():
						@warning_ignore("return_value_discarded")
						output.append(element)
						element = ""
					after_comma = false
				else:
					element += ch
					if not in_string:
						after_comma = true
			39:
				single_quote = not single_quote
				if after_comma:
					element += " "; after_comma = false
				element += ch
			34:
				if not single_quote:
					double_quote = not double_quote
				if after_comma:
					element += " "; after_comma = false
				element += ch
			91:
				if not in_string:
					array_depth += 1
				if after_comma:
					element += " "; after_comma = false
				element += ch
			93:
				if not in_string:
					array_depth -= 1
				after_comma = false
				element += ch
			_:
				if after_comma:
					element += " "; after_comma = false
				element += ch
	if not element.is_empty():
		@warning_ignore("return_value_discarded")
		output.append(element)
	return output


## v7 — 128-entry lookup table replaces match dispatch (lazily initialised once)
static func _parse_parameter_set_v7(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	var buf_size := buf.size()
	if buf_size == 0:
		return output
	if _char_lut.is_empty():
		_char_lut.resize(128)
		_char_lut[10] = 1; _char_lut[32] = 2; _char_lut[34] = 3
		_char_lut[39] = 4; _char_lut[44] = 5; _char_lut[91] = 6; _char_lut[93] = 7
	var work := PackedByteArray()
	work.resize(buf_size)
	var wp := 0
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	var after_comma := false
	for c: int in buf:
		var in_string: bool = single_quote or double_quote
		match (_char_lut[c] if c < 128 else 0):
			1:  # newline
				if in_string:
					work[wp] = c; wp += 1
			2:  # space
				if in_string:
					work[wp] = c; wp += 1; after_comma = false
				elif array_depth > 0 and not after_comma:
					work[wp] = c; wp += 1
			3:  # double quote
				if not single_quote:
					double_quote = not double_quote
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			4:  # single quote
				single_quote = not single_quote
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			5:  # comma
				if array_depth == 0:
					if wp > 0:
						@warning_ignore("return_value_discarded")
						output.append(work.slice(0, wp).get_string_from_utf8())
						wp = 0
					after_comma = false
				else:
					work[wp] = c; wp += 1
					if not in_string:
						after_comma = true
			6:  # open bracket
				if not in_string:
					array_depth += 1
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			7:  # close bracket
				if not in_string:
					array_depth -= 1
				after_comma = false
				work[wp] = c; wp += 1
			_:  # normal char
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
	if wp > 0:
		@warning_ignore("return_value_discarded")
		output.append(work.slice(0, wp).get_string_from_utf8())
	return output


## v8 — two-pass: pass 1 records element boundary positions, pass 2 cleans each slice
static func _parse_parameter_set_v8(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	var buf_size := buf.size()
	if buf_size == 0:
		return output
	# Pass 1: locate element boundaries (depth-0 commas)
	var boundaries: Array[Vector2i] = []
	var sq := false
	var dq := false
	var depth := 0
	var elem_start := 0
	for i in buf_size:
		var c: int = buf[i]
		match c:
			39: if not dq: sq = not sq
			34: if not sq: dq = not dq
			91: if not sq and not dq: depth += 1
			93: if not sq and not dq: depth -= 1
			44: if depth == 0 and not sq and not dq:
					boundaries.append(Vector2i(elem_start, i))
					elem_start = i + 1
	if elem_start < buf_size:
		boundaries.append(Vector2i(elem_start, buf_size))
	# Pass 2: clean each element slice
	var work := PackedByteArray()
	for b: Vector2i in boundaries:
		var slice_size: int = b.y - b.x
		if slice_size == 0:
			continue
		work.resize(slice_size)
		var wp := 0
		var single_quote := false
		var double_quote := false
		var array_depth := 0
		var after_comma := false
		for i in range(b.x, b.y):
			var c: int = buf[i]
			var in_string: bool = single_quote or double_quote
			match c:
				32:
					if in_string:
						work[wp] = c; wp += 1; after_comma = false
					elif array_depth > 0 and not after_comma:
						work[wp] = c; wp += 1
				10:
					if in_string:
						work[wp] = c; wp += 1
				44:
					work[wp] = c; wp += 1
					if not in_string:
						after_comma = true
				39:
					single_quote = not single_quote
					if after_comma:
						work[wp] = 32; wp += 1; after_comma = false
					work[wp] = c; wp += 1
				34:
					if not single_quote:
						double_quote = not double_quote
					if after_comma:
						work[wp] = 32; wp += 1; after_comma = false
					work[wp] = c; wp += 1
				91:
					if not in_string:
						array_depth += 1
					if after_comma:
						work[wp] = 32; wp += 1; after_comma = false
					work[wp] = c; wp += 1
				93:
					if not in_string:
						array_depth -= 1
					after_comma = false
					work[wp] = c; wp += 1
				_:
					if after_comma:
						work[wp] = 32; wp += 1; after_comma = false
					work[wp] = c; wp += 1
		if wp > 0:
			var elem := work.slice(0, wp).get_string_from_utf8()
			if not elem.is_empty():
				@warning_ignore("return_value_discarded")
				output.append(elem)
	return output


## v9 — dynamic push_back PAB; no pre-allocation, no write pointer
static func _parse_parameter_set_v9(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	if buf.size() == 0:
		return output
	var work := PackedByteArray()
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	var after_comma := false
	for c: int in buf:
		var in_string: bool = single_quote or double_quote
		match c:
			32:
				if in_string:
					work.push_back(c); after_comma = false
				elif array_depth > 0 and not after_comma:
					work.push_back(c)
			10:
				if in_string:
					work.push_back(c)
			44:
				if array_depth == 0:
					if work.size() > 0:
						@warning_ignore("return_value_discarded")
						output.append(work.get_string_from_utf8())
						work.clear()
					after_comma = false
				else:
					work.push_back(c)
					if not in_string:
						after_comma = true
			39:
				single_quote = not single_quote
				if after_comma:
					work.push_back(32); after_comma = false
				work.push_back(c)
			34:
				if not single_quote:
					double_quote = not double_quote
				if after_comma:
					work.push_back(32); after_comma = false
				work.push_back(c)
			91:
				if not in_string:
					array_depth += 1
				if after_comma:
					work.push_back(32); after_comma = false
				work.push_back(c)
			93:
				if not in_string:
					array_depth -= 1
				after_comma = false
				work.push_back(c)
			_:
				if after_comma:
					work.push_back(32); after_comma = false
				work.push_back(c)
	if work.size() > 0:
		@warning_ignore("return_value_discarded")
		output.append(work.get_string_from_utf8())
	return output


## v10 — bulk-copy normal-char runs via append_array(slice); C++ memcpy for the common case
static func _parse_parameter_set_v10(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	var buf_size := buf.size()
	if buf_size == 0:
		return output
	var work := PackedByteArray()
	var single_quote := false
	var double_quote := false
	var array_depth := 0
	var after_comma := false
	var i := 0
	while i < buf_size:
		var c: int = buf[i]
		if c != 10 and c != 32 and c != 34 and c != 39 and c != 44 and c != 91 and c != 93:
			if after_comma:
				work.push_back(32); after_comma = false
			var run_start := i
			i += 1
			while i < buf_size:
				var nc: int = buf[i]
				if nc == 10 or nc == 32 or nc == 34 or nc == 39 or nc == 44 or nc == 91 or nc == 93:
					break
				i += 1
			work.append_array(buf.slice(run_start, i))
			continue
		var in_string: bool = single_quote or double_quote
		match c:
			32:
				if in_string:
					work.push_back(c); after_comma = false
				elif array_depth > 0 and not after_comma:
					work.push_back(c)
			10:
				if in_string:
					work.push_back(c)
			44:
				if array_depth == 0:
					if work.size() > 0:
						@warning_ignore("return_value_discarded")
						output.append(work.get_string_from_utf8())
						work.clear()
					after_comma = false
				else:
					work.push_back(c)
					if not in_string:
						after_comma = true
			39:
				single_quote = not single_quote
				if after_comma:
					work.push_back(32); after_comma = false
				work.push_back(c)
			34:
				if not single_quote:
					double_quote = not double_quote
				if after_comma:
					work.push_back(32); after_comma = false
				work.push_back(c)
			91:
				if not in_string:
					array_depth += 1
				if after_comma:
					work.push_back(32); after_comma = false
				work.push_back(c)
			93:
				if not in_string:
					array_depth -= 1
				after_comma = false
				work.push_back(c)
		i += 1
	if work.size() > 0:
		@warning_ignore("return_value_discarded")
		output.append(work.get_string_from_utf8())
	return output


## v11 — bit-packed quote state: single int instead of two bools
static func _parse_parameter_set_v11(input: String) -> PackedStringArray:
	if not input.contains("["):
		return []
	input = _cleanup_leading_spaces.sub(input, "", true)
	input = input.strip_edges().trim_prefix("[").trim_suffix("]").trim_prefix("]")
	var output := PackedStringArray()
	var buf := input.to_utf8_buffer()
	var buf_size := buf.size()
	if buf_size == 0:
		return output
	var work := PackedByteArray()
	work.resize(buf_size)
	var wp := 0
	var quote_state := 0  # bit 0 = single_quote, bit 1 = double_quote
	var array_depth := 0
	var after_comma := false
	for c: int in buf:
		var in_string: bool = quote_state != 0
		match c:
			32:
				if in_string:
					work[wp] = c; wp += 1; after_comma = false
				elif array_depth > 0 and not after_comma:
					work[wp] = c; wp += 1
			10:
				if in_string:
					work[wp] = c; wp += 1
			44:
				if array_depth == 0:
					if wp > 0:
						@warning_ignore("return_value_discarded")
						output.append(work.slice(0, wp).get_string_from_utf8())
						wp = 0
					after_comma = false
				else:
					work[wp] = c; wp += 1
					if not in_string:
						after_comma = true
			39:
				quote_state ^= 1
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			34:
				if not (quote_state & 1):
					quote_state ^= 2
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			91:
				if not in_string:
					array_depth += 1
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
			93:
				if not in_string:
					array_depth -= 1
				after_comma = false
				work[wp] = c; wp += 1
			_:
				if after_comma:
					work[wp] = 32; wp += 1; after_comma = false
				work[wp] = c; wp += 1
	if wp > 0:
		@warning_ignore("return_value_discarded")
		output.append(work.slice(0, wp).get_string_from_utf8())
	return output


## value converters

func as_array(value: String) -> Array:
	if value == "Array()" or value == "[]":
		return []

	if value.begins_with("Array("):
		value = value.lstrip("Array(").rstrip(")")
	if value.begins_with("["):
		return str_to_var(value)
	return []


func as_dictionary(value: String) -> Dictionary:
	if value == "Dictionary()":
		return {}
	if value.begins_with("Dictionary("):
		value = value.lstrip("Dictionary(").rstrip(")")
	if value.begins_with("{"):
		return str_to_var(value)
	return {}
