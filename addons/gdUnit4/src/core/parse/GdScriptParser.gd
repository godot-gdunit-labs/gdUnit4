class_name GdScriptParser
extends RefCounted

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")
const TYPE_VOID := GdObjects.TYPE_VOID
const TYPE_VARIANT := GdObjects.TYPE_VARIANT
const TYPE_VARARG := GdObjects.TYPE_VARARG
const TYPE_FUNC := GdObjects.TYPE_FUNC
const TYPE_FUZZER := GdObjects.TYPE_FUZZER
const TYPE_ENUM := GdObjects.TYPE_ENUM

var _token_not_match := Token.new("")
var _token_space := SkippableToken.new(" ")
var _token_tabulator := SkippableToken.new("\t")
var _token_new_line := SkippableToken.new("\n")
var _token_comment := SkippableToken.new("#")
var _token_annotation := SkippableToken.new("@")
var _token_class_name := RegExToken.new("class_name", GdUnitTools.to_regex("(class_name)\\s+([\\w\\p{L}\\p{N}_]+) (extends[a-zA-Z]+:)|(class_name)\\s+([\\w\\p{L}\\p{N}_]+)"), 5)
var _token_inner_class := TokenInnerClass.new("class", GdUnitTools.to_regex("(class)\\s+(\\w\\p{L}\\p{N}_]+) (extends[a-zA-Z]+:)|(class)\\s+([\\w\\p{L}\\p{N}_]+)"), 5)
var _token_extends := RegExToken.new("extends", GdUnitTools.to_regex("extends\\s+"))
var _token_enum := RegExToken.new("enum", GdUnitTools.to_regex("enum\\s+"))
var _token_function_static_declaration := RegExToken.new("static func", GdUnitTools.to_regex("^static\\s+func\\s+([\\w\\p{L}\\p{N}_]+)"), 1)
var _token_function_declaration := RegExToken.new("func", GdUnitTools.to_regex("^func\\s+([\\w\\p{L}\\p{N}_]+)"), 1)
var _token_function := Token.new(".")
var _token_function_return_type := Token.new("->")
var _token_function_end := Token.new("):")
var _token_argument_asignment := Token.new("=")
var _token_argument_type_asignment := Token.new(":=")
var _token_argument_fuzzer := FuzzerToken.new(GdUnitTools.to_regex("((?!(fuzzer_(seed|iterations)))fuzzer?\\w+)( ?+= ?+| ?+:= ?+| ?+:Fuzzer ?+= ?+|)"))
var _token_argument_type := Token.new(":")
var _token_argument_variadic := Token.new("...")
var _token_argument_separator := Token.new(",")
var _token_bracket_round_open := Token.new("(")
var _token_bracket_round_close := Token.new(")")
var _token_bracket_square_open := Token.new("[")
var _token_bracket_square_close := Token.new("]")
var _token_bracket_curly_open := Token.new("{")
var _token_bracket_curly_close := Token.new("}")
var _token_backslash := Token.new("\\")
var _operator_add := Operator.new("+")
var _operator_sub := Operator.new("-")
var _operator_mul := Operator.new("*")
var _operator_div := Operator.new("/")
var _operator_remainder := Operator.new("%")
var _tokens: Array[Token] = [
	_token_space,
	_token_tabulator,
	_token_new_line,
	_token_backslash,
	_token_comment,
	_token_annotation,
	_token_bracket_round_open,
	_token_bracket_round_close,
	_token_bracket_square_open,
	_token_bracket_square_close,
	_token_bracket_curly_open,
	_token_bracket_curly_close,
	_token_class_name,
	_token_inner_class,
	_token_extends,
	_token_enum,
	_token_function_static_declaration,
	_token_function_declaration,
	_token_argument_fuzzer,
	_token_argument_type_asignment,
	_token_argument_asignment,
	_token_argument_type,
	_token_argument_variadic,
	_token_function,
	_token_argument_separator,
	_token_function_return_type,
	_operator_add,
	_operator_sub,
	_operator_mul,
	_operator_div,
	_operator_remainder,
]
var _regex_strip_comments := GdUnitTools.to_regex("^([^#\"']|'[^']*'|\"[^\"]*\")*\\K#.*")
var _scanned_inner_classes := PackedStringArray()
var _script_constants := {}
var _is_awaiting := GdUnitTools.to_regex("\\bawait\\s+(?![^\"]*\"[^\"]*$)(?!.*#.*await)")


static func to_unix_format(input: String) -> String:
	return input.replace("\r\n", "\n")


class Token extends RefCounted:
	var _token: String
	var _consumed: int
	var _is_operator: bool

	func _init(p_token: String, p_is_operator := false) -> void:
		_token = p_token
		_is_operator = p_is_operator
		_consumed = p_token.length()

	func match(input: String, pos: int) -> bool:
		return input.findn(_token, pos) == pos


	func value() -> Variant:
		return _token


	func is_operator() -> bool:
		return _is_operator


	func is_inner_class() -> bool:
		return _token == "class"


	func is_variable() -> bool:
		return false


	func is_token(token_name: String) -> bool:
		return _token == token_name


	func is_skippable() -> bool:
		return false


	func _to_string() -> String:
		return "Token{" + _token + "}"


class Operator extends Token:
	func _init(p_value: String) -> void:
		super(p_value, true)

	func _to_string() -> String:
		return "OperatorToken{%s}" % [_token]


# A skippable token, is just a placeholder like space or tabs
class SkippableToken extends Token:

	func _init(p_token: String) -> void:
		super(p_token)

	func is_skippable() -> bool:
		return true


# Token to parse function arguments
class Variable extends Token:
	var _plain_value: String
	var _typed_value: Variant
	var _type: int = TYPE_NIL

	func _init(p_value: String) -> void:
		super(p_value)
		_type = _scan_type(p_value)
		_plain_value = p_value
		_typed_value = _cast_to_type(p_value, _type)

	func _scan_type(p_value: String) -> int:
		if p_value.begins_with("\"") and p_value.ends_with("\""):
			return TYPE_STRING
		var value_type := GdObjects.string_to_type(p_value)
		if value_type != TYPE_NIL:
			return value_type
		if p_value.is_valid_int():
			return TYPE_INT
		if p_value.is_valid_float():
			return TYPE_FLOAT
		if p_value.is_valid_hex_number():
			return TYPE_INT
		return TYPE_OBJECT

	func _cast_to_type(p_value: String, p_type: int) -> Variant:
		match p_type:
			TYPE_STRING:
				return p_value  # .substr(1, p_value.length() - 2)
			TYPE_INT:
				return p_value.to_int()
			TYPE_FLOAT:
				return p_value.to_float()
		return p_value

	func is_variable() -> bool:
		return true

	func type() -> int:
		return _type

	func value() -> Variant:
		return _typed_value

	func plain_value() -> String:
		return _plain_value

	func _to_string() -> String:
		return "Variable{%s: %s : '%s'}" % [_plain_value, GdObjects.type_as_string(_type), _token]


class RegExToken extends Token:
	var _regex: RegEx
	var _extract_group_index: int
	var _value := ""

	func _init(token: String, regex: RegEx, extract_group_index: int = -1) -> void:
		super(token, false)
		_regex = regex
		_extract_group_index = extract_group_index

	func match(input: String, pos: int) -> bool:
		var matching := _regex.search(input, pos)
		if matching == null or pos != matching.get_start():
			return false
		if _extract_group_index != -1:
			_value = matching.get_string(_extract_group_index)
		_consumed = matching.get_end() - matching.get_start()
		return true


	func value() -> String:
		return _value


# Token to parse Fuzzers
class FuzzerToken extends RegExToken:


	func _init(regex: RegEx) -> void:
		super("fuzzer", regex, 1)

	func name() -> String:
		return value()

	func type() -> int:
		return GdObjects.TYPE_FUZZER

	func _to_string() -> String:
		return "FuzzerToken{%s: '%s'}" % [value(), _token]


class TokenInnerClass extends RegExToken:
	var _content := PackedStringArray()


	func _init(token: String, p_regex: RegEx, extract_group_index: int = -1) -> void:
		super(token, p_regex, extract_group_index)


	static func _strip_leading_spaces(input: String) -> String:
		var characters := input.to_utf8_buffer()
		while not characters.is_empty():
			if characters[0] != 0x20:
				break
			characters.remove_at(0)
		return characters.get_string_from_utf8()


	static func _consumed_bytes(row: String) -> int:
		return row.replace(" ", "").replace("	", "").length()


	func is_class_name(clazz_name: String) -> bool:
		return value() == clazz_name


	func content() -> PackedStringArray:
		return _content


	func parse(source_rows: PackedStringArray, offset: int) -> void:
		# add class signature
		_content.clear()
		@warning_ignore_start("return_value_discarded")
		_content.append(source_rows[offset])
		# parse class content
		for row_index in range(offset + 1, source_rows.size()):
			# scan until next non tab
			var source_row := source_rows[row_index]
			var row := TokenInnerClass._strip_leading_spaces(source_row)
			if row.is_empty() or row.begins_with("\t") or row.begins_with("#"):
				# fold all line to left by removing leading tabs and spaces
				if source_row.begins_with("\t"):
					source_row = source_row.trim_prefix("\t")
				# refomat invalid empty lines
				if source_row.dedent().is_empty():
					_content.append("")
				else:
					_content.append(source_row)
				continue
			break
		@warning_ignore_restore("return_value_discarded")
		_consumed += TokenInnerClass._consumed_bytes("".join(_content))


	func _to_string() -> String:
		return "TokenInnerClass{%s}" % [value()]


func get_token(input: String, current_index: int) -> Token:
	for t in _tokens:
		if t.match(input, current_index):
			return t
	return _token_not_match


func next_token(input: String, current_index: int, ignore_tokens: Array[Token] = []) -> Token:
	var token := _token_not_match
	for t: Token in _tokens.filter(func(t: Token) -> bool: return not ignore_tokens.has(t)):
		if t.match(input, current_index):
			token = t
			break
	if token == _operator_sub:
		token = tokenize_value(input, current_index, token)
	if token == _token_not_match:
		return tokenize_value(input, current_index, token, ignore_tokens.has(_token_function))
	return token


func tokenize_value(input: String, current: int, token: Token, ignore_dots := false) -> Token:
	var next := 0
	var current_token := ""
	# test for '--', '+-', '*-', '/-', '%-', or at least '-x'
	var test_for_sign := (token == null or token.is_operator()) and input[current] == "-"
	while current + next < len(input):
		var character := input[current + next] as String
		# if first charater a sign
		# or allowend charset
		# or is a float value
		if (test_for_sign and next == 0) \
			or is_allowed_character(character) \
			or (character == "." and (ignore_dots or current_token.is_valid_int())):
			current_token += character
			next += 1
			continue
		break
	if current_token != "":
		return Variable.new(current_token)
	return _token_not_match


# gdlint: disable=max-returns
# const ALLOWED_CHARACTERS := "0123456789_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\""
func is_allowed_character(input: String) -> bool:
	var code_point := input.unicode_at(0)
	# Unicode
	if code_point > 127:
		# This is a Unicode character (Chinese, Japanese, etc.)
		return true
	# ASCII digit 0-9
	if code_point >= 48 and code_point <= 57:
		return true
	# ASCII lowercase a-z
	if code_point >= 97 and code_point <= 122:
		return true
	# ASCII uppercase A-Z
	if code_point >= 65 and code_point <= 90:
		return true
	# underscore _
	if code_point == 95:
		return true
	# quotes '"
	if code_point == 34 or code_point == 39:
		return true
	return false
	# gdlint: enable=max-returns


func parse_return_token(input: String) -> Variable:
	var index := input.rfind(_token_function_return_type._token)
	if index == -1:
		return _token_not_match
	index += _token_function_return_type._consumed
	# We scan for the return value exclusive '.' token because it could be referenced to a
	# external or internal class e.g.  'func foo() -> InnerClass.Bar:'
	var token := next_token(input, index, [_token_function])
	while not token.is_variable() and token != _token_not_match:
		index += token._consumed
		token = next_token(input, index, [_token_function])
	return token


func get_function_descriptors(script: GDScript, included_functions: PackedStringArray = []) -> Array[GdFunctionDescriptor]:
	var fds: Array[GdFunctionDescriptor] = []
	for method_descriptor in script.get_script_method_list():
		var func_name: String = method_descriptor["name"]
		if included_functions.is_empty() or func_name in included_functions:
			# exclude type set/geters
			if is_getter_or_setter(func_name):
				continue
			if not fds.any(func(fd: GdFunctionDescriptor) -> bool: return fd.name() == func_name):
				fds.append(GdFunctionDescriptor.extract_from(method_descriptor, false))

	# we need to enrich it by default arguments and line number by parsing the script
	# the engine core functions has no valid methods to get this info
	_prescan_script(script)
	_enrich_function_descriptor(script, fds)
	return fds


func is_getter_or_setter(func_name: String) -> bool:
	return func_name.begins_with("@") and (func_name.ends_with("getter") or func_name.ends_with("setter"))


func _parse_function_arguments(input: String) -> Array[Dictionary]:
	var arguments: Array[Dictionary] = []
	var current_index := 0
	var token: Token = null
	var bracket := 0
	var in_function := false

	while current_index < len(input):
		token = next_token(input, current_index)
		# fallback to not end in a endless loop
		if token == _token_not_match:
			var error: = """
				Parsing Error: Invalid token at pos %d found.
				Please report this error!
				source_code:
				--------------------------------------------------------------
				%s
				--------------------------------------------------------------
			""".dedent() % [current_index, input]
			push_error(error)
			current_index += 1
			continue
		current_index += token._consumed
		if token.is_skippable():
			continue
		if token == _token_bracket_round_open:
			in_function = true
			bracket += 1
		if token == _token_bracket_round_close:
			bracket -= 1
		# if function end?
		if in_function and bracket == 0:
			return arguments
		# is function
		if token == _token_function_declaration:
			continue

		# is value argument
		if in_function:
			var arg_value := ""
			var current_argument := {
				"name": "",
				"value": GdFunctionArgument.UNDEFINED,
				"type": TYPE_VARIANT,
			}

			# parse type and default value
			while current_index < len(input):
				token = next_token(input, current_index)
				current_index += token._consumed
				if token.is_skippable():
					continue

				if token.is_variable() and current_argument["name"] == "":
					arguments.append(current_argument)
					current_argument["name"] = (token as Variable).plain_value()
					continue

				match token:
							# is fuzzer argument
					_token_argument_fuzzer:
						arg_value = _parse_end_function(input.substr(current_index), true)
						current_index += arg_value.length()
						current_argument["name"] = (token as FuzzerToken).name()
						current_argument["value"] = arg_value.lstrip(" ")
						current_argument["type"] = TYPE_FUZZER
						arguments.append(current_argument)
						continue

					_token_argument_variadic:
						current_argument["type"] = TYPE_VARARG

					_token_argument_type:
						token = next_token(input, current_index)
						if token == _token_space:
							current_index += token._consumed
							token = next_token(input, current_index)
							current_index += token._consumed
						if current_argument["type"] != TYPE_VARARG:
							current_argument["type"] = GdObjects.string_to_type((token as Variable).plain_value())

					_token_argument_type_asignment:
						arg_value = _parse_end_function(input.substr(current_index), true)
						current_index += arg_value.length()
						current_argument["value"] = arg_value.lstrip(" ")
					_token_argument_asignment:
						token = next_token(input, current_index)
						arg_value = _parse_end_function(input.substr(current_index), true)
						current_index += arg_value.length()
						current_argument["value"] = arg_value.lstrip(" ")

					_token_bracket_square_open:
						bracket += 1
					_token_bracket_curly_open:
						bracket += 1
					_token_bracket_round_open:
						bracket += 1
						# if value a function?
						if bracket > 1:
							# complete the argument value
							var func_begin := input.substr(current_index - _token_bracket_round_open._consumed)
							var func_body := _parse_end_function(func_begin)
							arg_value += func_body
							# fix parse index to end of value
							current_index += func_body.length() - _token_bracket_round_open._consumed - _token_bracket_round_close._consumed
					_token_bracket_square_close:
						bracket -= 1
					_token_bracket_curly_close:
						bracket -= 1
					_token_bracket_round_close:
						bracket -= 1
						# end of function
						if bracket == 0:
							break
					_token_argument_separator:
						if bracket <= 1:
							# next argument
							current_argument = {
								"name": "",
								"value": GdFunctionArgument.UNDEFINED,
								"type": GdObjects.TYPE_VARIANT,
							}
							continue
	return arguments


## Finds the index of the next [param quote_char] in [param input] starting at [param start],
## skipping backslash-escaped characters (e.g. [code]\"[/code]) so escaped quotes do not end the string.
## Returns -1 when no unescaped quote is found.
func _find_unescaped_quote(input: String, quote_char: String, start: int) -> int:
	var index := start
	while index < input.length():
		var character := input[index]
		if character == "\\":
			index += 2
			continue
		if character == quote_char:
			return index
		index += 1
	return -1


func _parse_end_function(input: String, remove_trailing_char := false) -> String:
	# find end of function
	var current_index := 0
	var bracket_count := 0
	var in_array := 0
	var in_dict := 0
	var end_of_func := false

	while current_index < len(input) and not end_of_func:
		var character := input[current_index]
		# step over strings
		if character == "'":
			current_index = _find_unescaped_quote(input, "'", current_index + 1) + 1
			if current_index == 0:
				push_error("Parsing error on '%s', can't evaluate end of string." % input)
				return ""
			continue
		if character == '"':
			# test for string blocks
			if input.find('"""', current_index) == current_index:
				current_index = input.find('"""', current_index + 3) + 3
			else:
				current_index = _find_unescaped_quote(input, '"', current_index + 1) + 1
			if current_index == 0:
				push_error("Parsing error on '%s', can't evaluate end of string." % input)
				return ""
			continue

		match character:
			# count if inside an array
			"[": in_array += 1
			"]": in_array -= 1
			# count if inside an dictionary
			"{": in_dict += 1
			"}": in_dict -= 1
			# count if inside a function
			"(": bracket_count += 1
			")":
				bracket_count -= 1
				if bracket_count < 0 and in_array <= 0 and in_dict <= 0:
					end_of_func = true
			",":
				if bracket_count == 0 and in_array == 0 and in_dict <= 0:
					end_of_func = true
		current_index += 1
	if remove_trailing_char:
		# check if the parsed value ends with comma or end of doubled breaked
		# `<value>,` or `<function>())`
		var trailing_char := input[current_index - 1]
		if trailing_char == "," or (bracket_count < 0 and trailing_char == ")"):
			return input.substr(0, current_index - 1)
	return input.substr(0, current_index)


func extract_inner_class(source_rows: PackedStringArray, clazz_name: String) -> PackedStringArray:
	for row_index in source_rows.size():
		var input := source_rows[row_index]
		var token := next_token(input, 0)
		if token.is_inner_class():
			@warning_ignore("unsafe_method_access")
			if token.is_class_name(clazz_name):
				@warning_ignore("unsafe_method_access")
				token.parse(source_rows, row_index)
				@warning_ignore("unsafe_method_access")
				return token.content()
	return PackedStringArray()


func extract_func_signature(rows: PackedStringArray, index: int) -> String:
	var signature := ""

	for row_idx in range(index, rows.size()):
		var row := rows[row_idx]
		row = _regex_strip_comments.sub(row, "").strip_edges(false)
		if row.is_empty():
			continue
		signature += row + "\n"
		if is_func_end(row):
			return signature.strip_edges()
	push_error("Can't fully extract function signature of '%s'" % rows[index])
	return ""


func get_class_name(script: GDScript) -> String:
	var source_code := GdScriptParser.to_unix_format(script.source_code)
	var source_rows := source_code.split("\n")

	for index: int in min(10, source_rows.size()):
		var input := source_rows[index]
		var token := next_token(input, 0)
		if token == _token_class_name:
			return token.value()
	# if no class_name found extract from file name
	return GdObjects.to_pascal_case(script.resource_path.get_basename().get_file())


func parse_func_name(input: String) -> String:
	if _token_function_declaration.match(input, 0):
		return _token_function_declaration.value()
	if _token_function_static_declaration.match(input, 0):
		return _token_function_static_declaration.value()
	push_error("Can't extract function name from '%s'" % input)
	return ""


## Enriches the function descriptor by line number and argument default values
## - enrich all function descriptors form current script up to all inherited scrips
func _enrich_function_descriptor(script: GDScript, fds: Array[GdFunctionDescriptor]) -> void:
	var enriched_functions := {}  # Use Dictionary for O(1) lookup instead of PackedStringArray
	var script_to_scan := script
	while script_to_scan != null:
		# do not scan the test suite base class itself
		if script_to_scan.resource_path == "res://addons/gdUnit4/src/GdUnitTestSuite.gd":
			break

		var rows := script_to_scan.source_code.split("\n")
		for row_idx in rows.size():
			var input := rows[row_idx]
			# step over inner class functions
			if input.begins_with("\t"):
				continue
			# skip comments and empty lines
			if input.begins_with("#") or input.length() == 0:
				continue
			var token := next_token(input, 0)
			if token != _token_function_static_declaration and token != _token_function_declaration:
				continue

			var function_name: String = token.value()
			# Skip if already enriched (from parent class scan)
			if enriched_functions.has(function_name):
				continue

			# Find matching function descriptor
			var fd: GdFunctionDescriptor = null
			for candidate in fds:
				if candidate.name() == function_name:
					fd = candidate
					break
			if fd == null:
				continue
			# Mark as enriched
			enriched_functions[function_name] = true
			var func_signature := extract_func_signature(rows, row_idx)
			var func_arguments := _parse_function_arguments(func_signature)
			var func_begin_line := row_idx + 1
			var func_end_line := _parse_func_end_line(rows, func_begin_line)
			# enrich missing default values
			fd.enrich_arguments(func_arguments)
			fd.enrich_file_info(script_to_scan.resource_path, func_begin_line, func_end_line)
			fd._is_coroutine = is_func_coroutine(rows, row_idx)
			# enrich return class name if not set
			if fd.return_type() == TYPE_OBJECT and fd._return_class in ["", "Resource", "RefCounted"]:
				var var_token := parse_return_token(func_signature)
				if var_token != _token_not_match and var_token.type() == TYPE_OBJECT:
					fd._return_class = _patch_inner_class_names(var_token.plain_value(), "")
		# if the script ihnerits we need to scan this also
		script_to_scan = script_to_scan.get_base_script()


func _parse_func_end_line(rows: PackedStringArray, func_row_index: int) -> int:
	var last_non_empty := func_row_index
	for row_index in range(func_row_index, rows.size()):
		var row := rows[row_index]
		if row.begins_with("#") or row.is_empty():
			continue
		var token := next_token(row, 0)
		# scan until next function or annotation
		if token in [_token_annotation, _token_function_static_declaration, _token_function_declaration]:
			break
		last_non_empty = row_index
	return last_non_empty + 1


func is_func_coroutine(rows: PackedStringArray, index: int) -> bool:
	var is_coroutine := false
	for row_idx in range(index + 1, rows.size()):
		var input := rows[row_idx].strip_edges()
		if input.begins_with("#") or input.is_empty():
			continue
		var token := next_token(input, 0)
		# scan until next function
		if token == _token_function_static_declaration or token == _token_function_declaration:
			break

		if _is_awaiting.search(input):
			return true
	return is_coroutine


func is_inner_class(clazz_path: PackedStringArray) -> bool:
	return clazz_path.size() > 1


func is_func_end(row: String) -> bool:
	return row.strip_edges(false, true).ends_with(":")


func _patch_inner_class_names(clazz: String, clazz_name: String = "") -> String:
	var inner_clazz_name := clazz.split(".")[0]
	if _scanned_inner_classes.has(inner_clazz_name):
		return inner_clazz_name
		#var base_clazz := clazz_name.split(".")[0]
		#return base_clazz + "." + clazz
	if _script_constants.has(clazz):
		return clazz_name + "." + clazz
	return clazz


func _prescan_script(script: GDScript) -> void:
	_script_constants = script.get_script_constant_map()
	for key: String in _script_constants.keys():
		var value: Variant = _script_constants.get(key)
		if value is GDScript:
			@warning_ignore("return_value_discarded")
			_scanned_inner_classes.append(key)


func parse(clazz_name: String, clazz_path: PackedStringArray) -> GdUnitResult:
	if clazz_path.is_empty():
		return GdUnitResult.error("Invalid script path '%s'" % clazz_path)
	var is_inner := is_inner_class(clazz_path)
	var script: GDScript = load(clazz_path[0])
	_prescan_script(script)

	if is_inner:
		var inner_class_name := clazz_path[1]
		if _scanned_inner_classes.has(inner_class_name):
			# do load only on inner class source code and enrich the stored script instance
			var source_code := _load_inner_class(script, inner_class_name)
			script = _script_constants.get(inner_class_name)
			script.source_code = source_code
	var function_descriptors := get_function_descriptors(script)
	var gd_class := GdClassDescriptor.new(clazz_name, is_inner, function_descriptors)
	return GdUnitResult.success(gd_class)


func _load_inner_class(script: GDScript, inner_clazz: String) -> String:
	var source_rows := GdScriptParser.to_unix_format(script.source_code).split("\n")
	# extract all inner class names
	var inner_class_code := extract_inner_class(source_rows, inner_clazz)
	return "\n".join(inner_class_code)
