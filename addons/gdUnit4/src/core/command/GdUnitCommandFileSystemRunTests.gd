class_name GdUnitCommandFileSystemRunTests
extends GdUnitCommandFileSystem


const ID := "Run FileSystem Tests"


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.RUN_TESTSUITE)
	icon =  GdUnitUiTools.get_icon("Play")


func execute(...parameters: Array) -> void:
	var selected_paths: PackedStringArray = parameters[0]
	execute_tests(selected_paths, false)
