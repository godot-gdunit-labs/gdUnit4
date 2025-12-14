class_name GdUnitCommandTestSession
extends GdUnitBaseCommand


const ID := "Start TestSession"


enum PARAMS {
	START,
	STOP
}


var _current_runner_process_id: int


func _init() -> void:
	super(ID, GdUnitShortcut.ShortCut.NONE)


func execute(...parameters: Array) -> void:
	var mode: PARAMS = parameters[0]
	if mode == PARAMS.START:
		var arguments := Array()
		if OS.is_stdout_verbose():
			arguments.append("--verbose")
		arguments.append("--no-window")
		arguments.append("--path")
		arguments.append(ProjectSettings.globalize_path("res://"))
		arguments.append("res://addons/gdUnit4/src/core/runners/GdUnitTestRunner.tscn")
		_current_runner_process_id = OS.create_process(OS.get_executable_path(), arguments, false);
	elif mode == PARAMS.STOP:
		if OS.is_process_running(_current_runner_process_id):
			var result := OS.kill(_current_runner_process_id)
			if result != OK:
				push_error("ERROR checked stopping GdUnit Test Runner. error code: %s" % result)
			_current_runner_process_id = -1
	else:
		push_error("ERROR invalid command argument: %s" % parameters)
