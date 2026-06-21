class_name GdParameterSetResolverFactory
extends RefCounted

static var _global_class_type_mapping: Dictionary[String, Variant] = {}


## Creates the appropriate [GdParameterSetResolver] for the given test function descriptor.
## Returns null when the function is not parameterized.
static func create(fd: GdFunctionDescriptor, instance: Node) -> GdParameterSetResolver:
	if not fd.is_parameterized():
		return null
	var parameter_set_argument := GdFunctionArgument.get_parameter_set(fd.args())
	var parameter_sets := parameter_set_argument.parameter_sets()
	if not parameter_sets.is_empty():
		return GdInlineParameterSetResolver.new(parameter_sets)

	# Check for Callable or property expression
	var expression: String = parameter_set_argument._default_value
	if expression.contains("("):
		return GdCallableParameterSetResolver.new(instance, expression)
	return GdPropertyParameterSetResolver.new(instance, expression)




## Returns the shared class-name-to-Godot-type mapping, building it once on first access.
static func get_class_type_mapping() -> Dictionary[String, Variant]:
	if _global_class_type_mapping.is_empty():
		_global_class_type_mapping = _build_class_type_mapping()
	return _global_class_type_mapping


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
