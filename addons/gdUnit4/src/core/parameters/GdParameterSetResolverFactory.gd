class_name GdParameterSetResolverFactory
extends RefCounted


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
