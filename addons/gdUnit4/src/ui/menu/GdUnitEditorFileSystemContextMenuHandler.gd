@tool
extends EditorContextMenuPlugin

var _context_menus: Dictionary[GdUnitContextMenuItem.MENU_ID, GdUnitContextMenuItem] = {}


func _init() -> void:
	var is_test_suite := func is_visible(script: Script, is_ts: bool) -> bool:
		if script == null:
			return false
		return GdUnitTestSuiteScanner.is_test_suite(script) == is_ts
	var command_handler := GdUnitCommandHandler.instance()
	_context_menus[GdUnitContextMenuItem.MENU_ID.TEST_RUN] = GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_RUN, "Run Testsuites", "Play", is_test_suite.bind(true), command_handler.get_command(GdUnitCommandHandler.CMD_RUN_TESTSUITE))
	_context_menus[GdUnitContextMenuItem.MENU_ID.TEST_DEBUG] = GdUnitContextMenuItem.new(GdUnitContextMenuItem.MENU_ID.TEST_DEBUG, "Debug Testsuites", "PlayStart", is_test_suite.bind(true), command_handler.get_command(GdUnitCommandHandler.CMD_RUN_TESTSUITE_DEBUG))

	# setup shortcuts
	for menu_item: GdUnitContextMenuItem  in _context_menus.values():
		var cb := func call(files: Array) -> void:
			menu_item.execute([files])
		add_menu_shortcut(menu_item.shortcut(), cb)


func _popup_menu(paths: PackedStringArray) -> void:
	var test_suites: Array[Script] = []
	var suite_scaner := GdUnitTestSuiteScanner.new()

	for resource_path in paths:
		# directories and test-suites are valid to enable the menu
		if DirAccess.dir_exists_absolute(resource_path):
			test_suites.append_array(suite_scaner.scan_directory(resource_path))
			continue

		var file_type := resource_path.get_extension()
		if file_type == "gd" or file_type == "cs":
			var script: Script = ResourceLoader.load(resource_path, "Script", ResourceLoader.CACHE_MODE_REUSE)
			if GdUnitTestSuiteScanner.is_test_suite(script):
				test_suites.append(script)

	# no direcory or test-suites selected?
	if test_suites.is_empty():
		return

	for menu_item: GdUnitContextMenuItem  in _context_menus.values():
		add_context_menu_item(menu_item.name, menu_item.execute.bind(test_suites).unbind(1), GdUnitUiTools.get_icon(menu_item.icon))
