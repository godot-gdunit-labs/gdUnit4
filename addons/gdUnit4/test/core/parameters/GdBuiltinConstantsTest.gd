# GdUnit generated TestSuite
extends GdUnitTestSuite


#region is_known_constant
func test_is_known_constant_resolves_vector_constants() -> void:
	assert_bool(GdBuiltinConstants.is_known_constant("Vector2", "Vector2.ONE")).is_true()
	assert_bool(GdBuiltinConstants.is_known_constant("Vector3", "Vector3.INF")).is_true()
	assert_bool(GdBuiltinConstants.is_known_constant("Vector4i", "Vector4i.MAX")).is_true()


func test_is_known_constant_resolves_color_constants_without_manual_mapping() -> void:
	assert_bool(GdBuiltinConstants.is_known_constant("Color", "Color.RED")).is_true()
	assert_bool(GdBuiltinConstants.is_known_constant("Color", "Color.WEB_GRAY")).is_true()


func test_is_known_constant_rejects_unsupported_type() -> void:
	assert_bool(GdBuiltinConstants.is_known_constant("String", "String.NOPE")).is_false()
	assert_bool(GdBuiltinConstants.is_known_constant("Foo", "Foo.BAR")).is_false()
#endregion

#region value_of
func test_value_of_returns_resolved_value() -> void:
	assert_bool(GdBuiltinConstants.is_known_constant("Vector2", "Vector2.ONE")).is_true()
	assert_object(GdBuiltinConstants.value_of("Vector2.ONE")).is_equal(Vector2.ONE)

	assert_bool(GdBuiltinConstants.is_known_constant("Color", "Color.RED")).is_true()
	assert_object(GdBuiltinConstants.value_of("Color.RED")).is_equal(Color.RED)
#endregion
