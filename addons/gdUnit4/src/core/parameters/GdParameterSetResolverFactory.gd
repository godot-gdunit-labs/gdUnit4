## Factory that selects and constructs the correct [GdParameterSetResolver] for a
## parameterized test function based on how the [code]_test_parameters[/code] default
## value is expressed: inline array literals, a callable, or a property reference.
class_name GdParameterSetResolverFactory
extends RefCounted

## Lazily built map from Godot class name to a live instance, used by
## [GdInlineParameterSetResolver] to resolve class-name tokens inside inline expressions.
static var _global_class_type_mapping: Dictionary[String, Variant] = {}


## Returns the appropriate resolver for [param fd], or null when the function is not parameterized.
static func create(fd: GdFunctionDescriptor, instance: Node) -> GdParameterSetResolver:
	if not fd.is_parameterized():
		return null
	var parameter_set_argument := GdFunctionArgument.get_parameter_set(fd.args())
	var parameter_sets := parameter_set_argument.parameter_sets()

	if not parameter_sets.is_empty():
		return GdInlineParameterSetResolver.new(parameter_sets, fd.args())

	# A parenthesis signals a callable expression, e.g. "my_provider()".
	var expression: String = parameter_set_argument._default_value
	if expression.contains("("):
		return GdCallableParameterSetResolver.new(instance, expression, fd.args())
	return GdPropertyParameterSetResolver.new(instance, expression, fd.args())


## Returns the shared class-name-to-instance map, building it once on first access.
static func get_class_type_mapping() -> Dictionary[String, Variant]:
	if _global_class_type_mapping.is_empty():
		_global_class_type_mapping = _build_class_type_mapping()
	return _global_class_type_mapping


## Builds the class-name-to-instance map by generating and executing a GDScript that
## returns a dictionary literal — the only way to obtain live class references from
## [ClassDB] names, since GDScript has no eval or direct class-by-name lookup.
static func _build_class_type_mapping() -> Dictionary[String, Variant]:
	var source := """
		extends RefCounted

		func get_class_type_mappings() -> Dictionary[String, Variant]:
			return {
		""".dedent()

	for clazz_name in ClassDB.get_class_list():
		if ClassDB.class_get_api_type(clazz_name) != 0 or not ClassDB.can_instantiate(clazz_name):
			continue
		if clazz_name.is_valid_identifier():
			source += '\t\t"%s": %s,\n' % [clazz_name, clazz_name]
	source += "\t}"

	var script := GDScript.new()
	script.source_code = source
	var err := script.reload()
	if err != OK:
		prints("Failed to build class:type mappings: %s" % error_string(err))
		return {}

	@warning_ignore("unsafe_method_access")
	return script.new().get_class_type_mappings()
