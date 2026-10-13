# A tool to provide extended script editor functionallity
class_name GdUnitScriptEditorControls
extends RefCounted


const FILE_CLOSE := 1
const FILE_CLOSE_ALL := 2
const FILE_SAVE := 3
const FILE_SAVE_ALL := 4


# Saves the given script and closes if requested by <close=true>
# The script is saved when is opened in the editor.
# The script is closed when <close> is set to true.
static func save_and_close_script(script_path: String, close := false) -> bool:
	if !Engine.is_editor_hint():
		return false

	var editor := EditorInterface.get_script_editor()
	# search for the script in all opened editor scrips
	for open_script in editor.get_open_scripts():
		if open_script.resource_path == script_path:
			# select the script in the editor
			EditorInterface.edit_script(open_script, 0)
			run_file_command(FILE_SAVE)
			if close:
				run_file_command(FILE_CLOSE)
			return true
	return false


# Saves all opened script
static func save_all_open_script() -> void:
	run_file_command(FILE_SAVE_ALL)


static func close_open_editor_scripts() -> void:
	run_file_command(FILE_CLOSE_ALL)


# Edits the given script.
# The script is openend in the current editor and selected in the file system dock.
# The line and column on which to open the script can also be specified.
# The script will be open with the user-configured editor for the script's language which may be an external editor.
static func edit_script(script_path: String, line_number := -1) -> void:
	if Engine.is_editor_hint():
		# scan() is required — update_file() alone does not refresh the dock for newly created files
		var file_system := EditorInterface.get_resource_filesystem()
		file_system.update_file(script_path)
		file_system.scan()
		var file_system_dock := EditorInterface.get_file_system_dock()
		file_system_dock.navigate_to_path(script_path)
		EditorInterface.select_file(script_path)
		var script: GDScript = load(script_path)
		EditorInterface.edit_script(script, line_number)


static func run_file_command(command_id: int) -> void:
	if !Engine.is_editor_hint():
		return

	match command_id:
		FILE_SAVE, FILE_SAVE_ALL:
			EditorInterface.get_script_editor().save_all_scripts()
		FILE_CLOSE, FILE_CLOSE_ALL:
			var script := EditorInterface.get_script_editor().get_current_script()
			EditorInterface.get_script_editor().close_file(script.resource_path)
