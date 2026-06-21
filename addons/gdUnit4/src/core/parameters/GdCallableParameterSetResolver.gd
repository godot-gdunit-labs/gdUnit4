class_name GdCallableParameterSetResolver
extends GdParameterSetResolver


var _expression: String
var _parameters: Array[Array]

var _func_call_regex := RegEx.create_from_string("^(\\w+)\\((.*)\\)$")


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

	for parameters: Array in parameter_set:
		_finalize_parameter_set(parameters)

	# We want to use allways typed arrays
	if not parameter_set.is_typed():
		parameter_set = Array(parameter_set, TYPE_ARRAY, "", null)

	return parameter_set


func _parse_arguments(args_str: String) -> Array:
	var result: Array = []
	for raw: String in args_str.split(","):
		var value := raw.strip_edges()
		var converted: Variant = str_to_var(value)
		result.append(converted if converted != null else value)
	return result
