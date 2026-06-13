## Provides editor theme colors sourced from [EditorSettings].
## Add this node to the scene tree so it auto-refreshes colors when the
## editor theme changes ([constant EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED]).
@tool
class_name GdUnitEditorColorTheme
extends Node


static var text_color := Color.WEB_GRAY
static var folder_color := Color.LIGHT_SKY_BLUE
static var function_definition_color := Color.ANTIQUE_WHITE
static var engine_type_color := Color.ANTIQUE_WHITE
static var value_color := Color.DODGER_BLUE

# test state colors
static var state_initial := Color.LIGHT_GRAY
static var state_success := Color.WEB_GREEN
static var state_warning := Color.DARK_GOLDENROD
static var state_flaky := Color.GREEN_YELLOW
static var state_failure := Color.ORANGE_RED
static var state_error := Color.DARK_RED
static var state_skipped := Color.WEB_GRAY
static var state_orphan := Color.DARK_GOLDENROD


func _ready() -> void:
	setup()


func _notification(what: int) -> void:
	if what == EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED:
		setup()


static func setup() -> void:
	if Engine.is_editor_hint():
		var settings := EditorInterface.get_editor_settings()
		text_color = settings.get_setting("text_editor/theme/highlighting/text_color")
		folder_color = settings.get_setting("text_editor/theme/highlighting/member_variable_color")
		function_definition_color = settings.get_setting("text_editor/theme/highlighting/gdscript/function_definition_color")
		engine_type_color = settings.get_setting("text_editor/theme/highlighting/engine_type_color")
		value_color = settings.get_setting("text_editor/theme/highlighting/function_color")
		# init test state colors
		state_initial = text_color
		state_success = settings.get_setting("editors/animation/onion_layers_future_color")
		state_warning = settings.get_setting("text_editor/theme/highlighting/comment_markers/warning_color")
		state_flaky = settings.get_setting("text_editor/theme/highlighting/gdscript/node_reference_color")
		state_failure = settings.get_setting("text_editor/theme/highlighting/comment_markers/critical_color")
		state_error = settings.get_setting("editors/2d/smart_snapping_line_color")
		state_orphan = settings.get_setting("text_editor/theme/highlighting/string_placeholder_color")
