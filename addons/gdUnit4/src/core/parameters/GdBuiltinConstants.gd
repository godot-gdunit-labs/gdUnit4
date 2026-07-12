class_name GdBuiltinConstants
extends RefCounted


## Built-in Variant types that expose named constants via static member access (e.g. `Vector2.ONE`,
## `Color.RED`). This gate is what keeps resolution silent: only tokens whose type is listed here are
## compiled, so arbitrary `Identifier.UPPER` matches (enum refs, text) never reach the parser.
## New builtin types are rare, so this list changes far less often than the constants themselves.
const CONSTANT_BEARING_TYPES: PackedStringArray = [
	"Vector2", "Vector2i",
	"Vector3", "Vector3i",
	"Vector4", "Vector4i",
	"Color",
	"Basis", "Quaternion", "Plane",
	"Transform2D", "Transform3D", "Projection",
]

const _RESOLVE_SCRIPT_TEMPLATE := """
extends RefCounted

func value() -> Variant:
	return %s
"""

static var _resolved_values: Dictionary[String, Variant] = {}
static var _unresolvable_tokens: Dictionary[String, bool] = {}


## Resolves a dotted constant token (e.g. `Vector2.ONE`) to its runtime value, compiling it once and
## caching the result process-wide. Returns true when the token is a known constant of a supported
## builtin type; its value is then available via [method value_of].
static func is_known_constant(type_name: String, token: String) -> bool:
	if _resolved_values.has(token):
		return true
	if _unresolvable_tokens.has(token) or not CONSTANT_BEARING_TYPES.has(type_name):
		return false

	var script := GDScript.new()
	script.source_code = _RESOLVE_SCRIPT_TEMPLATE % token
	if script.reload() != OK:
		_unresolvable_tokens[token] = true
		return false

	@warning_ignore("unsafe_method_access")
	_resolved_values[token] = script.new().call("value")
	return true


static func value_of(token: String) -> Variant:
	return _resolved_values[token]
