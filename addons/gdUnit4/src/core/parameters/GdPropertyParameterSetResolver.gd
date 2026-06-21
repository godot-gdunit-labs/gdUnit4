class_name GdPropertyParameterSetResolver
extends GdParameterSetResolver

var _parameters: Array[Array]
var _property_name: String


func _init(instance: Node, property_name: String) -> void:
	_parameters = _resolve_property(instance, property_name)
	_property_name = property_name


func get_max_index() -> int:
	return _parameters.size()


func get_parameters(instance: Node, index: int) -> Array:
	return _resolve_property(instance, _property_name)[index]


func _resolve_property(instance: Node, property_name: String) -> Array[Array]:
	var result: Variant = instance.get(property_name)

	if result == null:
		prints("The property `%s` do not exists." % property_name)
		return []
	if not result is Array:
		prints("The property `%s` must be an Array" % property_name)
		return []

	var parameters: Array = result
	var resolved_parameters := parameters.duplicate(true)
	for parameter: Array in resolved_parameters:
		# We append an extra empty array representing the `_test_parameters` to prevent reinitalizice the test parameter set
		parameter.append(EMPTY_SET)

	# We want to use allways typed arrays
	if not resolved_parameters.is_typed():
		return Array(resolved_parameters, TYPE_ARRAY, "", null)
	return resolved_parameters
