class_name GdCallableParameterSetResolver
extends GdParameterSetResolver


var _expression: String
var _parameters: Array[Array]

static var _func_call_regex := RegEx.create_from_string("^(\\w+)\\((.*)\\)$")


func _init(instance: Node, expression: String) -> void:
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
	var parameters: Array = instance.callv(func_name, args)
	if parameters == null:
		return []

	# We append an extra empty array representing the `_test_parameters` to prevent reinitializing the test parameter set
	for parameter: Array in parameters:
		parameter.append(EMPTY_SET)

	# We want to use allways typed arrays
	if not parameters.is_typed():
		parameters = Array(parameters, TYPE_ARRAY, "", null)

	return parameters


func _parse_arguments(args_str: String) -> Array:
	var result: Array = []
	for raw: String in args_str.split(","):
		var value := raw.strip_edges()
		var converted: Variant = str_to_var(value)
		result.append(converted if converted != null else value)
	return result
