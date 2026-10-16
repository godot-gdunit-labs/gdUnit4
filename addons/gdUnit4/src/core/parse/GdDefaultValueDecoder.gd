# holds all decodings for default values
class_name GdDefaultValueDecoder
extends GdUnitSingleton

@warning_ignore("unused_parameter")
var _decoders := {
	TYPE_NIL: func(value: Variant) -> String: return "null",
	TYPE_STRING: func(value: Variant) -> String: return '"%s"' % value,
	TYPE_STRING_NAME: _on_type_string_name,
	TYPE_BOOL: func(value: Variant) -> String: return str(value).to_lower(),
	TYPE_FLOAT: func(value: Variant) -> String: return "%f" % value,
	TYPE_COLOR: _on_type_color,
	TYPE_ARRAY: _on_type_array.bind(TYPE_ARRAY),
	TYPE_PACKED_BYTE_ARRAY: _on_type_array.bind(TYPE_PACKED_BYTE_ARRAY),
	TYPE_PACKED_STRING_ARRAY: _on_type_array.bind(TYPE_PACKED_STRING_ARRAY),
	TYPE_PACKED_FLOAT32_ARRAY: _on_type_array.bind(TYPE_PACKED_FLOAT32_ARRAY),
	TYPE_PACKED_FLOAT64_ARRAY: _on_type_array.bind(TYPE_PACKED_FLOAT64_ARRAY),
	TYPE_PACKED_INT32_ARRAY: _on_type_array.bind(TYPE_PACKED_INT32_ARRAY),
	TYPE_PACKED_INT64_ARRAY: _on_type_array.bind(TYPE_PACKED_INT64_ARRAY),
	TYPE_PACKED_COLOR_ARRAY: _on_type_array.bind(TYPE_PACKED_COLOR_ARRAY),
	TYPE_PACKED_VECTOR2_ARRAY: _on_type_array.bind(TYPE_PACKED_VECTOR2_ARRAY),
	TYPE_PACKED_VECTOR3_ARRAY: _on_type_array.bind(TYPE_PACKED_VECTOR3_ARRAY),
	TYPE_PACKED_VECTOR4_ARRAY: _on_type_array.bind(TYPE_PACKED_VECTOR4_ARRAY),
	TYPE_DICTIONARY: _on_type_dictionary,
	TYPE_RID: _on_type_rid,
	TYPE_NODE_PATH: _on_type_node_path,
	TYPE_VECTOR2: _on_type_vector.bind(TYPE_VECTOR2),
	TYPE_VECTOR2I: _on_type_vector.bind(TYPE_VECTOR2I),
	TYPE_VECTOR3: _on_type_vector.bind(TYPE_VECTOR3),
	TYPE_VECTOR3I: _on_type_vector.bind(TYPE_VECTOR3I),
	TYPE_VECTOR4: _on_type_vector.bind(TYPE_VECTOR4),
	TYPE_VECTOR4I: _on_type_vector.bind(TYPE_VECTOR4I),
	TYPE_RECT2: _on_type_rect2,
	TYPE_RECT2I: _on_type_rect2i,
	TYPE_PLANE: _on_type_plane,
	TYPE_QUATERNION: _on_type_quaternion,
	TYPE_AABB: _on_type_aabb,
	TYPE_BASIS: _on_type_basis,
	TYPE_CALLABLE: _on_type_callable,
	TYPE_SIGNAL: _on_type_signal,
	TYPE_TRANSFORM2D: _on_type_transform2d,
	TYPE_TRANSFORM3D: _on_type_transform3d,
	TYPE_PROJECTION: _on_type_projection,
	TYPE_OBJECT: _on_type_object,
}


static func _regex(pattern: String) -> RegEx:
	var regex := RegEx.new()
	var err := regex.compile(pattern)
	if err != OK:
		push_error("error '%s' checked pattern '%s'" % [err, pattern])
		return null
	return regex


func get_decoder(type: int) -> Callable:
	return _decoders.get(type, func(value: Variant) -> String: return "%s" % value)


func _on_type_string_name(value: StringName) -> String:
	if value.is_empty():
		return "StringName()"
	return 'StringName("%s")' % value


func _on_type_object(value: Variant, _type: int) -> String:
	return str(value)


func _on_type_color(color: Color) -> String:
	if color == Color.BLACK:
		return "Color()"
	return "Color%s" % color


func _on_type_node_path(path: NodePath) -> String:
	if path.is_empty():
		return "NodePath()"
	return 'NodePath("%s")' % path


func _on_type_callable(_cb: Callable) -> String:
	return "Callable()"


func _on_type_signal(_s: Signal) -> String:
	return "Signal()"


func _on_type_dictionary(dict: Dictionary) -> String:
	if dict.is_empty():
		return "{}"
	return str(dict)


# gdlint: disable=max-returns
func _on_type_array(value: Variant, type: int) -> String:
	match type:
		TYPE_ARRAY:
			return str(value)

		TYPE_PACKED_COLOR_ARRAY:
			var colors := PackedStringArray()
			for color: Color in value:
				@warning_ignore("return_value_discarded")
				colors.append(_on_type_color(color))
			if colors.is_empty():
				return "PackedColorArray()"
			return "PackedColorArray([%s])" % ", ".join(colors)

		TYPE_PACKED_VECTOR2_ARRAY:
			var vectors := PackedStringArray()
			for vector: Vector2 in value:
				@warning_ignore("return_value_discarded")
				vectors.append(_on_type_vector(vector, TYPE_VECTOR2))
			if vectors.is_empty():
				return "PackedVector2Array()"
			return "PackedVector2Array([%s])" % ", ".join(vectors)

		TYPE_PACKED_VECTOR3_ARRAY:
			var vectors := PackedStringArray()
			for vector: Vector3 in value:
				@warning_ignore("return_value_discarded")
				vectors.append(_on_type_vector(vector, TYPE_VECTOR3))
			if vectors.is_empty():
				return "PackedVector3Array()"
			return "PackedVector3Array([%s])" % ", ".join(vectors)

		TYPE_PACKED_VECTOR4_ARRAY:
			var vectors := PackedStringArray()
			for vector: Vector4 in value:
				@warning_ignore("return_value_discarded")
				vectors.append(_on_type_vector(vector, TYPE_VECTOR4))
			if vectors.is_empty():
				return "PackedVector4Array()"
			return "PackedVector4Array([%s])" % ", ".join(vectors)

		TYPE_PACKED_STRING_ARRAY:
			var values := PackedStringArray()
			for v: String in value:
				@warning_ignore("return_value_discarded")
				values.append('"%s"' % v)
			if values.is_empty():
				return "PackedStringArray()"
			return "PackedStringArray([%s])" % ", ".join(values)

		TYPE_PACKED_BYTE_ARRAY, \
		TYPE_PACKED_FLOAT32_ARRAY, \
		TYPE_PACKED_FLOAT64_ARRAY, \
		TYPE_PACKED_INT32_ARRAY, \
		TYPE_PACKED_INT64_ARRAY:
			var vectors := PackedStringArray()
			for vector: Variant in value:
				@warning_ignore("return_value_discarded")
				vectors.append(str(vector))
			if vectors.is_empty():
				return GdObjects.type_as_string(type) + "()"
			return "%s([%s])" % [GdObjects.type_as_string(type), ", ".join(vectors)]
	return "unknown array type %d" % type


func _on_type_vector(value: Variant, type: int) -> String:
	if typeof(value) != type:
		push_error("Internal Error: type missmatch detected for value '%s', expects type %s" % [value, type_string(type)])
		return ""

	match type:
		TYPE_VECTOR2:
			if value == Vector2():
				return "Vector2()"
			return "Vector2%s" % value
		TYPE_VECTOR2I:
			if value == Vector2i():
				return "Vector2i()"
			return "Vector2i%s" % value
		TYPE_VECTOR3:
			if value == Vector3():
				return "Vector3()"
			return "Vector3%s" % value
		TYPE_VECTOR3I:
			if value == Vector3i():
				return "Vector3i()"
			return "Vector3i%s" % value
		TYPE_VECTOR4:
			if value == Vector4():
				return "Vector4()"
			return "Vector4%s" % value
		TYPE_VECTOR4I:
			if value == Vector4i():
				return "Vector4i()"
			return "Vector4i%s" % value
	return "unknown vector type %d" % type
	# gdlint: enable=max-returns


func _on_type_transform2d(transform: Transform2D) -> String:
	if transform == Transform2D():
		return "Transform2D()"
	return "Transform2D(Vector2%s, Vector2%s, Vector2%s)" % [transform.x, transform.y, transform.origin]


func _on_type_transform3d(transform: Transform3D) -> String:
	if transform == Transform3D():
		return "Transform3D()"
	return "Transform3D(Vector3%s, Vector3%s, Vector3%s, Vector3%s)" % [transform.basis.x, transform.basis.y, transform.basis.z, transform.origin]


func _on_type_projection(projection: Projection) -> String:
	return "Projection(Vector4%s, Vector4%s, Vector4%s, Vector4%s)" % [projection.x, projection.y, projection.z, projection.w]


@warning_ignore("unused_parameter")
func _on_type_rid(_value: RID) -> String:
	return "RID()"


func _on_type_rect2(rect: Rect2) -> String:
	if rect == Rect2():
		return "Rect2()"
	return "Rect2(Vector2%s, Vector2%s)" % [rect.position, rect.size]


func _on_type_rect2i(rect: Variant) -> String:
	if rect == Rect2i():
		return "Rect2i()"
	return "Rect2i(Vector2i%s, Vector2i%s)" % [rect.position, rect.size]


func _on_type_plane(plane: Plane) -> String:
	if plane == Plane():
		return "Plane()"
	return "Plane(%d, %d, %d, %d)" % [plane.x, plane.y, plane.z, plane.d]


func _on_type_quaternion(quaternion: Quaternion) -> String:
	if quaternion == Quaternion():
		return "Quaternion()"
	return "Quaternion(%d, %d, %d, %d)" % [quaternion.x, quaternion.y, quaternion.z, quaternion.w]


func _on_type_aabb(aabb: AABB) -> String:
	if aabb == AABB():
		return "AABB()"
	return "AABB(Vector3%s, Vector3%s)" % [aabb.position, aabb.size]


func _on_type_basis(basis: Basis) -> String:
	if basis == Basis():
		return "Basis()"
	return "Basis(Vector3%s, Vector3%s, Vector3%s)" % [basis.x, basis.y, basis.z]


static func decode(value: Variant) -> String:
	var type := typeof(value)
	@warning_ignore("unsafe_cast")
	if GdArrayTools.is_type_array(type) and (value as Array).is_empty():
		return "<empty>"
	# For Variant types we need to determine the original type
	if type == GdObjects.TYPE_VARIANT:
		type = typeof(value)
	var decoder := _get_value_decoder(type)
	if decoder == null:
		push_error("No value decoder registered for type '%d'! Please open a Bug issue at 'https://github.com/MikeSchulze/gdUnit4/issues/new/choose'." % type)
		return "null"
	if type == TYPE_OBJECT:
		return decoder.call(value, type)
	return decoder.call(value)


static func decode_typed(type: int, value: Variant) -> String:
	if value == null:
		return "null"
	# For Variant types we need to determine the original type
	if type == GdObjects.TYPE_VARIANT:
		type = typeof(value)
	var decoder := _get_value_decoder(type)
	if decoder == null:
		push_error("No value decoder registered for type '%d'! Please open a Bug issue at 'https://github.com/MikeSchulze/gdUnit4/issues/new/choose'." % type)
		return "null"
	if type == TYPE_OBJECT:
		return decoder.call(value, type)
	return decoder.call(value)


static func _get_value_decoder(type: int) -> Callable:
	var decoder: GdDefaultValueDecoder = instance(
		"GdUnitDefaultValueDecoders",
		func() -> GdDefaultValueDecoder:
			return GdDefaultValueDecoder.new())
	return decoder.get_decoder(type)
