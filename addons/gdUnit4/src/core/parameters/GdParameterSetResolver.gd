## Abstract base class for all parameterized test resolvers.
## Subclasses resolve the concrete parameter values for each test iteration from
## different sources (inline literals, callable, or a property reference).
## The base class pre-builds a [ParameterSpec] list from the test function's
## parameter descriptors and provides a shared [method validate] implementation.
@abstract class_name GdParameterSetResolver
extends RefCounted

## Placeholder written into the [code]_test_parameters[/code] position of a resolved
## parameter array to prevent re-initialization of the test data on the next invocation.
const EMPTY_SET: Array[Array] = []


## Describes a single test function parameter and the type contract it must satisfy.
class ParameterSpec:
	## Position of this parameter in the resolved parameter array.
	var index: int
	## The GDScript type constant ([code]TYPE_*[/code]) the resolved value must match.
	var type: int
	## [code]true[/code] when this parameter is [code]_test_parameters[/code] — internal, not a user-supplied test input.
	var is_parameter_set: bool
	## Human-readable representation used in validation error messages.
	var declaration: String

	func _init(p_index: int, p_type: int, p_is_parameter_set: bool, p_declaration: String) -> void:
		index = p_index
		type = p_type
		is_parameter_set = p_is_parameter_set
		declaration = p_declaration


## Comma-separated display string of the user-supplied parameter names.
var _parameter_names := ""
## Ordered specs for every parameter in the test function.
var _parameter_specs: Array[ParameterSpec] = []


func _init(args: Array[GdFunctionArgument] = []) -> void:
	_build_parameter_specs(args)


## Builds [member _parameter_specs] and [member _parameter_names] from the test function descriptors.
func _build_parameter_specs(args: Array[GdFunctionArgument] = []) -> void:
	var parameter_names: PackedStringArray = []
	for param_index in args.size():
		var param: GdFunctionArgument = args[param_index]
		var param_str := str(param)
		var param_type := param.type()
		if param.is_parameter_set():
			_parameter_specs.append(ParameterSpec.new(param_index, TYPE_ARRAY, true, param_str))
		else:
			parameter_names.append(param_str)
			_parameter_specs.append(ParameterSpec.new(param_index, param_type, false, param_str))
	_parameter_names = ",".join(parameter_names)


## Validates [param parameters] against the parameter specs.
## Returns an error result when the count or any type does not match the test function signature.
func validate(parameters: Array, index: int) -> GdUnitResult:
	if _parameter_specs.is_empty() and parameters.is_empty():
		return GdUnitResult.success("ok")

	if parameters.size() != _parameter_specs.size():
		# Exclude the _test_parameters value — it is internal, not a user-supplied test input.
		var test_values := parameters.slice(0, parameters.size() - 1)
		return GdUnitResult.error("""
			The test data set at index (%d) does not match the expected test parameters:
				test function: [color=snow]func test...(%s)[/color]
				test input values: [color=snow]%s[/color]
			""".dedent() % [index, _parameter_names, test_values])

	for spec: ParameterSpec in _parameter_specs:
		var parameter_value: Variant = parameters[spec.index]
		var current_type := typeof(parameter_value)
		var type := spec.type
		if spec.is_parameter_set:
			# _test_parameters must always carry an empty Array — anything else is a resolver bug.
			var test_parameters: Array = parameter_value
			if typeof(test_parameters) != TYPE_ARRAY or not test_parameters.is_empty():
				var msg := "GdParameterSetResolver: '%s' must provide an empty Array for the '_test_parameters' parameter but got '%s'." \
					+ " This is unexpected — please report it as a bug."
				push_error(msg % [get_class(), test_parameters])
			continue

		# Untyped or Variant parameters accept any value — skip the type check.
		if type in [TYPE_NIL, GdObjects.TYPE_VARIANT]:
			continue
		# Object-typed parameters accept null.
		if type == TYPE_OBJECT and current_type == TYPE_NIL:
			continue

		if type != current_type:
			return GdUnitResult.error("""
				The test data value does not match the expected input type!
					input value: [color=snow]'%s', <%s>[/color]
					expected parameter: [color=snow]%s[/color]
				""".dedent() % [parameter_value, type_string(current_type), spec.declaration])

	return GdUnitResult.success("ok")


## Appends [constant EMPTY_SET] to [param parameters] to prevent re-initialisation of the
## [code]_test_parameters[/code] default value on the next invocation.
## Duplicates [param parameters] first when it is read-only (e.g. a GDScript class constant).
func _finalize_parameter_set(parameters: Array) -> Array:
	if parameters.is_read_only():
		parameters = parameters.duplicate()
	parameters.append(EMPTY_SET)
	return parameters


## Returns the resolved parameter values for the given test iteration index.
@abstract func get_parameters(instance: Node, index: int) -> Array


## Returns the total number of test iterations this resolver provides.
@abstract func get_max_index() -> int
