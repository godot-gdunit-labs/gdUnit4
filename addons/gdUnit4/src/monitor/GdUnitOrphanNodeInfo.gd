class_name GdUnitOrphanNodeInfo
extends RefCounted

enum GdUnitOrphanType {
	member,
	variable,
	unknown
}


var _id: int
var _orphan_type: GdUnitOrphanType
var _type: String
var _name: String
var _script_ref: String
var _func_ref: String
var _next: GdUnitOrphanNodeInfo

func _init(orphan_type: GdUnitOrphanType, id: int, type: String, name: String, script_ref: String, func_ref: String = "") -> void:
	_orphan_type = orphan_type
	_id = id
	_type = type
	_name = name
	_script_ref = script_ref
	_func_ref = func_ref


func as_trace(info: GdUnitOrphanNodeInfo, show_orphan_id := true) -> String:
	var trace := ""
	if show_orphan_id:
		trace += "• <%s> Id:%s\n" % [
			_colored(info._type, GdUnitEditorColorTheme.engine_type_color),
			_colored(info._id, GdUnitEditorColorTheme.engine_type_color)]
	match info._orphan_type:
		GdUnitOrphanType.member:
			return trace + "	at  %s script: %s" % [
				_colored(info._name, GdUnitEditorColorTheme.engine_type_color),
				_colored(info._script_ref, GdUnitEditorColorTheme.engine_type_color)
				] + sub_info(info._next)
		GdUnitOrphanType.variable:
			return trace + "	at %s script: %s.%s()" % [
				_colored(info._name, GdUnitEditorColorTheme.engine_type_color),
				_colored(info._script_ref, GdUnitEditorColorTheme.engine_type_color),
				_colored(info._func_ref, GdUnitEditorColorTheme.function_definition_color),
				]
		GdUnitOrphanType.unknown:
			return trace + "	%s" % [
				_colored(info._name, GdUnitEditorColorTheme.engine_type_color)
				]

		_:
			return trace + "	No details available"


func sub_info(next: GdUnitOrphanNodeInfo) -> String:
	if next == null:
		return ""

	return "\n" + as_trace(next, false)


static func _colored(value: Variant, color: Color) -> String:
	return "[color=%s]%s[/color]" % [color.to_html(), value]
