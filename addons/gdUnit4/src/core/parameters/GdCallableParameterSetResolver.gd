class_name GdCallableParameterSetResolver
extends GdParameterSetResolver

var _expression: String
var _parameters: Array[Array]
var _func_call_regex := RegEx.create_from_string("^(\\w+)\\((.*)\\)$")
var _string_regex := RegEx.create_from_string("^(['\"])(.*?)\\1$")


func _init(instance: Node, expression: String, args: Array[GdFunctionArgument] = []) -> void:
	super(args)
	_expression = expression
	_parameters = _compile(instance, expression)


func get_max_index() -> int:
	return _parameters.size()


func get_parameters(_instance: Node, index: int) -> Array:
	return _parameters[index]


func _compile(instance: Node, expression: String) -> Array[Array]:
	var regex_result := _func_call_regex.search(expression)
	if regex_result == null:
		push_error("GdCallableParameterSetResolver: Cannot parse expression '%s'" % expression)
		return []

	var func_name := regex_result.get_string(1)
	var args_str := regex_result.get_string(2).strip_edges()

	if not instance.has_method(func_name):
		push_error("GdCallableParameterSetResolver: Method '%s' not found on instance." % func_name)
		return []

	var args: Array = [] if args_str.is_empty() else _parse_arguments(args_str)
	var parameter_set: Array = instance.callv(func_name, args)
	if parameter_set == null:
		return []

	var result: Array[Array] = []
	result.resize(parameter_set.size())
	for index in parameter_set.size():
		result[index] = _finalize_parameter_set(parameter_set[index].duplicate())
	return result


func _parse_arguments(args_str: String) -> Array:
	var result: Array = []

	args_str = args_str.strip_edges()
	if args_str.is_empty():
		return result

	for raw: String in _split_argumens(args_str):
		var value := raw.strip_edges()
		var quoted_string_value := _string_regex.search(value)
		if quoted_string_value != null:
			result.append(quoted_string_value.get_string(2))
			continue
		result.append(str_to_var(value))
	return result


static func _split_argumens(input: String) -> Array[String]:
	var result: Array[String] = []
	var current := ""
	var in_quote := false
	var quote_char := ""
	var i := 0

	while i < input.length():
		var character := input[i]

		if character == "\\":
			if i + 1 < input.length():
				current += input[i + 1]
				i += 2
				continue

		if character == '"' or character == "'":
			if not in_quote:
				in_quote = true
				quote_char = character
			elif character == quote_char:
				in_quote = false
				quote_char = ""

			current += character
			i += 1
			continue

		if character == "," and not in_quote:
			result.append(current.strip_edges())
			current = ""
			i += 1
			continue

		current += character
		i += 1

	if current != "":
		result.append(current.strip_edges())
	return result
