class_name GdUnitCommandFileSystemDebugTests
extends GdUnitCommandFileSystem


const ID := "Debug FileSystem Tests"


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.RUN_TESTSUITE_DEBUG)
	icon =  GdUnitUiTools.get_icon("PlayStart")


func execute(...parameters: Array) -> void:
	if parameters.is_empty():
		return
	var selected_paths: PackedStringArray = parameters[0]
	execute_tests(selected_paths, true)
