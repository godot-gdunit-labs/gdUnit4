class_name GdUnitCommandStopTestSession
extends GdUnitBaseCommand

const ID := "Stop Test Session"


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.STOP_TEST_RUN)
	icon = GdUnitUiTools.get_icon("Stop")


func execute(..._parameters: Array) -> void:
	push_error("No not call `GdUnitCommandStopTestSession` direcly!")


func _do_stop() -> void:
	pass
