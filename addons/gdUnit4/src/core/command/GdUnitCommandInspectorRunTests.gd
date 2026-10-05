class_name GdUnitCommandInspectorRunTests
extends GdUnitCommandTestSession

const  GdUnitInspectorTreeMainPanel := preload("res://addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.gd")
const ID := "Run Inspector Tests"


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.RERUN_TESTS)
	icon = GdUnitUiTools.get_icon("Play")


func execute(..._parameters: Array) -> void:
	var base_control := EditorInterface.get_base_control()
	var inspector: GdUnitInspectorTreeMainPanel = base_control.get_meta("GdUnit4Inspector")
	var selected_item := inspector._tree.get_selected()
	var tests_to_execute := inspector.collect_test_cases(selected_item)
	super.execute(tests_to_execute, false)
