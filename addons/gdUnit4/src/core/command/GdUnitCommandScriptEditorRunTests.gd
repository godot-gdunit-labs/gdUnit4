class_name GdUnitCommandScriptEditorRunTests
extends GdUnitCommandScriptEditor


const ID := "Run ScriptEditor Tests"


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.RUN_TESTCASE)
	icon =  GdUnitUiTools.get_icon("Play")


func execute(..._parameters: Array) -> void:
	execute_tests(false)
