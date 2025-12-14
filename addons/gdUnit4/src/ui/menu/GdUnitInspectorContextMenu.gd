@tool
class_name GdUnitInspectorContextMenu
extends PopupMenu


signal run_tests(debug: bool)
signal run_tests_until_failure(debug: bool)
signal collapse_tree_item(collapse: bool)


const InspectorTreeMainPanel := preload("res://addons/gdUnit4/src/ui/parts/InspectorTreeMainPanel.gd")
const CONTEXT_MENU_RUN_ID = 0
const CONTEXT_MENU_DEBUG_ID = 1
const CONTEXT_MENU_RERUN_UNTIL_ID = 2
# id 3 is the seperator
const CONTEXT_MENU_COLLAPSE_ALL = 4
const CONTEXT_MENU_EXPAND_ALL = 5


var command_handler: GdUnitCommandHandler


func _ready() -> void:
	command_handler = GdUnitCommandHandler.instance()
	var inspector: InspectorTreeMainPanel = get_parent().get_parent().find_child("MainPanel", false, false)
	if inspector == null:
		push_error("Internal error, can't connect to the test inspector!")
	else:
		run_tests.connect(inspector._on_run_pressed)
		run_tests_until_failure.connect(inspector._on_run_tests_until_failure)
		collapse_tree_item.connect(inspector._on_collapse_tree_item)

	_setup_item(CONTEXT_MENU_RUN_ID, "Run Tests", "Play", GdUnitShortcut.ShortCut.RERUN_TESTS)
	_setup_item(CONTEXT_MENU_DEBUG_ID, "Debug Tests", "PlayStart", GdUnitShortcut.ShortCut.RERUN_TESTS_DEBUG)
	_setup_item(CONTEXT_MENU_RERUN_UNTIL_ID, "Run Tests Until Fail", "Play")
	_setup_item(CONTEXT_MENU_EXPAND_ALL, "Expand All", "ExpandTree")
	_setup_item(CONTEXT_MENU_COLLAPSE_ALL, "Collapse All", "CollapseTree")


func _setup_item(item_id: int, item_name: String, icon_name: String, short_cut := GdUnitShortcut.ShortCut.NONE) -> void:
	set_item_text(item_id, item_name)
	set_item_icon(item_id, GdUnitUiTools.get_icon(icon_name))
	if short_cut != GdUnitShortcut.ShortCut.NONE:
		set_item_shortcut(item_id, command_handler.get_shortcut(short_cut))


func disable_items() -> void:
	set_item_disabled(CONTEXT_MENU_RUN_ID, true)
	set_item_disabled(CONTEXT_MENU_DEBUG_ID, true)
	set_item_disabled(CONTEXT_MENU_RERUN_UNTIL_ID, true)


func enable_items() -> void:
	set_item_disabled(CONTEXT_MENU_RUN_ID, false)
	set_item_disabled(CONTEXT_MENU_DEBUG_ID, false)
	set_item_disabled(CONTEXT_MENU_RERUN_UNTIL_ID, false)


func _on_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int, source: Tree) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		position = source.get_screen_position() + mouse_position
		popup()


func _on_index_pressed(index: int) -> void:
	match index:
		CONTEXT_MENU_DEBUG_ID:
			run_tests.emit(true)
		CONTEXT_MENU_RUN_ID:
			run_tests.emit(false)
		CONTEXT_MENU_RERUN_UNTIL_ID:
			run_tests_until_failure.emit(true)
		CONTEXT_MENU_EXPAND_ALL:
			collapse_tree_item.emit(false)
		CONTEXT_MENU_COLLAPSE_ALL:
			collapse_tree_item.emit(true)
