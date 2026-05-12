## Provides editor theme colors sourced from [EditorSettings].
## Add this node to the scene tree so it auto-refreshes colors when the
## editor theme changes ([constant EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED]).
@tool
class_name GdUnitEditorColorTheme
extends Node


static var text_color := Color.ANTIQUE_WHITE
static var function_definition_color := Color.ANTIQUE_WHITE
static var engine_type_color := Color.ANTIQUE_WHITE


func _ready() -> void:
	init_colors()


func _notification(what: int) -> void:
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		init_colors()


func init_colors() -> void:
	if Engine.is_editor_hint():
		var settings := EditorInterface.get_editor_settings()
		text_color =  settings.get_setting("text_editor/theme/highlighting/text_color")
		function_definition_color = settings.get_setting("text_editor/theme/highlighting/gdscript/function_definition_color")
		engine_type_color = settings.get_setting("text_editor/theme/highlighting/engine_type_color")
