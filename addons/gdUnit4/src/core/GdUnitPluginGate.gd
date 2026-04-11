class_name GdUnitPluginGate
extends RefCounted

## Encapsulates the plugin-load gate that aborts `_enter_tree` when gdUnit4's
## own files would produce `inferred_declaration` parse errors. Extracted from
## plugin.gd so the decision can be unit-tested without instantiating the
## EditorPlugin.
##
## This file currently preserves the original exact-key `directory_rules`
## check from GD-1004 / PR #1043 verbatim (with the `dirctrory_rules` typo
## fixed). A follow-up commit replaces the internals of
## `is_addon_warnings_suppressed()` with a sorted-prefix walk that mirrors
## Godot's own rule evaluation in
## `GDScriptParser::evaluate_warning_directory_rules_for_script_path`.

const SETTING_INFERRED_DECLARATION := "debug/gdscript/warnings/inferred_declaration"
const SETTING_DIRECTORY_RULES := "debug/gdscript/warnings/directory_rules"
const SETTING_EXCLUDE_ADDONS := "debug/gdscript/warnings/exclude_addons"


## Returns true when `_enter_tree` should print the configuration error and
## abort plugin load. True only when `inferred_declaration` is set to Warn or
## Error AND the gdUnit4 addon path is not already excluded from warnings.
static func should_block_plugin_load() -> bool:
	var inferred_declaration: int = int(ProjectSettings.get_setting(
			SETTING_INFERRED_DECLARATION, 0))
	if inferred_declaration == 0:
		return false
	return not is_addon_warnings_suppressed()


## Returns true when the plugin believes Godot's warning rules would suppress
## warnings for `res://addons/gdUnit4/`. On Godot 4.6+ this reads
## `directory_rules`; on earlier versions it reads the deprecated
## `exclude_addons` setting (still valid for <4.6).
static func is_addon_warnings_suppressed() -> bool:
	if Engine.get_version_info().hex >= 0x40600:
		var directory_rules: Dictionary = ProjectSettings.get_setting(
				SETTING_DIRECTORY_RULES, {})
		return (directory_rules.has("res://addons/gdUnit4")
				and directory_rules["res://addons/gdUnit4"] == 0)
	return bool(ProjectSettings.get_setting(SETTING_EXCLUDE_ADDONS, true))


## User-facing help message printed alongside the block. Version-split to
## match the setting `is_addon_warnings_suppressed()` reads above.
static func build_block_help_message() -> String:
	if Engine.get_version_info().hex >= 0x40600:
		return ("GdUnit4 is not 'inferred_declaration' save, "
				+ "you have to excluded the addon "
				+ "(debug/gdscript/warnings/directory_rules)")
	return ("GdUnit4 is not 'inferred_declaration' save, "
			+ "you have to excluded addons "
			+ "(debug/gdscript/warnings/exclude_addons)")
