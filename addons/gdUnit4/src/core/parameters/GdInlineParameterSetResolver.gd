class_name GdInlineParameterSetResolver
extends GdParameterSetResolver


const EXCLUDE_PROPERTIES_TO_COPY := [
	"script",
	"type",
	"Node",
	"_import_path"]


const EXPRESSION_TEMPLATE := """
extends '${clazz_path}'

func __run_expression() -> Array:
	return ${test_params}

"""

var _expression: Expression
var _parameter_sets: PackedStringArray
var _used_input_types: Array[PackedStringArray] = []


## Lazily built map from Godot class name to a live instance, used by
## [GdInlineParameterSetResolver] to resolve class-name tokens inside inline expressions.
static var _global_class_type_mapping: Dictionary[String, Variant] = {}


func _init(parameter_sets: PackedStringArray, args: Array[GdFunctionArgument] = []) -> void:
	super(args)
	_expression = Expression.new()
	_parameter_sets = parameter_sets

	# Scan for used types
	for index in _used_input_types.resize(_parameter_sets.size()):
		_used_input_types[index] = PackedStringArray()

	for clazz_name: String in _get_class_type_mapping().keys():
		for parameter_set_index in _parameter_sets.size():
			var paramater_set := _parameter_sets[parameter_set_index]
			if paramater_set.contains(clazz_name):
				_used_input_types[parameter_set_index].append(clazz_name)


func get_max_index() -> int:
	return _used_input_types.size()


func get_parameters(instance: Node, index: int) -> Array:
	var mapping := _get_class_type_mapping()
	var input_values: Array = []

	for clazz_name in _used_input_types[index]:
		input_values.append(mapping[clazz_name])

	var expression := _parameter_sets[index]
	var parse_error := _expression.parse(expression, _used_input_types[index])
	if parse_error != OK:
		# TODO provide better error reporting
		prints("""
			Warning: Fallback to slower parameter resolving!
				GdInlineParameterSetResolver: parsing error: %s
				'%s'
				error: %s
			""".dedent() % [error_string(parse_error), expression, _expression.get_error_text()])
		return _run_expression_via_script(instance, expression)

	var parameters: Variant = _expression.execute(input_values, instance, false)
	if _expression.has_execute_failed():
		# TODO provide better error reporting
		prints("Expression execute error:", _expression.get_error_text())
		return _run_expression_via_script(instance, expression)
	if not parameters is Array:
		# The expression may reference a class const or property not accessible via Object.get();
		# fall back to a GDScript that extends the test class so it can resolve such identifiers.
		return _run_expression_via_script(instance, expression)

	@warning_ignore("unsafe_call_argument")
	return _finalize_parameter_set(parameters)


# This is a fallback option to run the expression by kind of reflection
func _run_expression_via_script(instance: Node, expression: String) -> Array:
	var source_script: GDScript = instance.get_script()
	var script := GDScript.new()
	script.source_code = EXPRESSION_TEMPLATE \
		.replace("${clazz_path}", source_script.resource_path) \
		.replace("${test_params}", expression)
	var debug := false
	if debug == true:
		# enable these lines only for debugging
		script.resource_path = GdUnitFileAccess.create_temp_dir("parameter_extract") + "/%sExpression.gd" % source_script.resource_path.get_file()
		DirAccess.remove_absolute(script.resource_path)
		ResourceSaver.save(script, script.resource_path)
	var result := script.reload()
	if result != OK:
		prints("Extracting test parameters failed! Script loading error: %s" % error_string(result))
		return []

	var expression_runner: Node = script.new()
	copy_properties(instance, expression_runner)
	var parameters: Array = expression_runner.call("__run_expression")
	expression_runner.free()
	return _finalize_parameter_set(parameters)


## Returns the shared class-name-to-instance map, building it once on first access.
static func _get_class_type_mapping() -> Dictionary[String, Variant]:
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


static func copy_properties(source: Object, dest: Object) -> void:
	for property in source.get_property_list():
		var property_name :String = property["name"]
		var property_value :Variant = source.get(property_name)
		if EXCLUDE_PROPERTIES_TO_COPY.has(property_name):
			continue
		#if dest.get(property_name) == null:
		#	prints("|%s|" % property_name, source.get(property_name))

		# check for invalid name property
		if property_name == "name" and property_value == "":
			dest.set(property_name, "<empty>");
			continue
		dest.set(property_name, property_value)
