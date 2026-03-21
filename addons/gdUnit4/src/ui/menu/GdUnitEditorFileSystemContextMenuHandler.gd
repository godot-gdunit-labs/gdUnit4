@tool
extends EditorContextMenuPlugin

var _context_menus: Array[GdUnitContextMenuItem] = []


func _init() -> void:
	var is_test_suite := func is_visible(script: Script, is_ts: bool) -> bool:
		if script == null:
			return false
		return GdUnitTestSuiteScanner.is_test_suite(script) == is_ts
	# setup shortcuts
	_context_menus.append(GdUnitContextMenuItem.new(
		GdUnitCommandFileSystemRunTests.ID,
		"Run Testsuites",
		is_test_suite.bind(true)
	))
	_context_menus.append(GdUnitContextMenuItem.new(
		GdUnitCommandFileSystemDebugTests.ID,
		"Debug Testsuites",
		is_test_suite.bind(true)
	))


func _popup_menu(paths: PackedStringArray) -> void:
	# Filter for test suites only
	var test_suites := Array(paths)\
		.filter(func(file: String) -> bool:
			return file.get_extension() in ["gd", "cs"])\
		.filter(func(file: String) -> bool:
			var script := GdUnitTestSuiteScanner.load_with_disabled_warnings(file)
			return GdUnitTestSuiteScanner.is_test_suite(script))

	# If no test suites selected don't extend the context menu
	if test_suites.is_empty():
		return

	for menu_item in _context_menus:
		if menu_item.shortcut():
			add_menu_shortcut(menu_item.shortcut(), menu_item.execute.bindv(test_suites).unbind(1))
			add_context_menu_item_from_shortcut(menu_item.name, menu_item.shortcut(), menu_item.icon)
		else:
			add_context_menu_item(menu_item.name, menu_item.execute.bindv(test_suites).unbind(1), menu_item.icon)
