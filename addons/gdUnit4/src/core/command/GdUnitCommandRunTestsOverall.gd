class_name GdUnitCommandRunTestsOverall
extends GdUnitCommandTestSession

const ID := "Run Tests Overall"


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.RUN_TESTS_OVERALL)
	icon = GdUnitUiTools.get_run_overall_icon()


func execute(..._parameters: Array) -> void:
	var tests_to_execute := await GdUnitTestDiscoverer.run()
	super.execute(tests_to_execute, true)
