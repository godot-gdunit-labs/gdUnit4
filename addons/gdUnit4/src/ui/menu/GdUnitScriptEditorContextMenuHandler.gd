@tool
extends EditorContextMenuPlugin

var _context_menus: Dictionary[GdUnitContextMenuItem.MENU_ID, GdUnitContextMenuItem] = {}


func _init() -> void:
	var is_test_suite := func is_visible(script: Script, is_ts: bool) -> bool:
		return GdUnitTestSuiteScanner.is_test_suite(script) == is_ts
	var command_handler := GdUnitCommandHandler.instance()
	_context_menus[GdUnitContextMenuItem.MENU_ID.TEST_RUN] = GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_RUN, "Run Tests", "Play", is_test_suite.bind(true), command_handler.get_command(GdUnitCommandHandler.CMD_RUN_TESTCASE))
	_context_menus[GdUnitContextMenuItem.MENU_ID.TEST_DEBUG] = GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_DEBUG, "Debug Tests", "PlayStart", is_test_suite.bind(true), command_handler.get_command(GdUnitCommandHandler.CMD_RUN_TESTCASE_DEBUG))
	_context_menus[GdUnitContextMenuItem.MENU_ID.CREATE_TEST] = GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.CREATE_TEST, "Create Test", "New", is_test_suite.bind(false), command_handler.get_command(GdUnitCommandHandler.CMD_CREATE_TESTCASE))

	# setup shortcuts
	for menu_item: GdUnitContextMenuItem  in _context_menus.values():
		var shortcut := menu_item.shortcut()
		add_menu_shortcut(menu_item.shortcut(), menu_item.execute.unbind(1))


func _popup_menu(_paths: PackedStringArray) -> void:
	var current_script := EditorInterface.get_script_editor().get_current_script()

	for menu_item: GdUnitContextMenuItem in _context_menus.values():
		if menu_item.is_visible(current_script):
			add_context_menu_item_from_shortcut(menu_item.name, menu_item.shortcut())
