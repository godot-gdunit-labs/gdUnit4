class_name GdUnitCommandTestSessionDebug
extends GdUnitBaseCommand


const ID := "Start Debug TestSession"


enum PARAMS {
	START,
	STOP
}


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.NONE)


func execute(...parameters: Array) -> void:
	var mode: PARAMS = parameters[0]
	if mode == PARAMS.START:
		EditorInterface.play_custom_scene("res://addons/gdUnit4/src/core/runners/GdUnitTestRunner.tscn")
	elif mode == PARAMS.STOP:
		EditorInterface.stop_playing_scene()
	else:
		push_error("ERROR invalid command argument: %s" % parameters)
