class_name GdUnitPluginGate
extends RefCounted

## Decides whether plugin.gd should abort in `_enter_tree` because gdUnit4's
## files would hit `inferred_declaration` parse errors. Extracted from plugin.gd
## so the logic can be tested without an EditorPlugin instance.
##
## On Godot 4.6+ this walks `directory_rules` by descending slash count and
## picks the most-specific prefix rule covering `res://addons/gdUnit4/`,
## mirroring `GDScriptParser::evaluate_warning_directory_rules_for_script_path`
## (see `modules/gdscript/gdscript_parser.cpp:141-147` for `RuleSort` and
## `:312-328` for the evaluator). On <4.6 it reads `exclude_addons`, the only
## suppression knob those versions have. We do NOT read `exclude_addons` on
## 4.6+: the engine deprecated it and migrates its value into `directory_rules`
## on first parser init (see `gdscript_parser.cpp:113-123`).

# The path we check against directory_rules to decide if gdUnit4's own files
# would be warning-suppressed. Trailing slash matches the engine's
# post-normalization form (see gdscript_parser.cpp:127-139).
const GDUNIT_ADDON_PATH := "res://addons/gdUnit4/"

const SETTING_INFERRED_DECLARATION := "debug/gdscript/warnings/inferred_declaration"
const SETTING_DIRECTORY_RULES := "debug/gdscript/warnings/directory_rules"
const SETTING_EXCLUDE_ADDONS := "debug/gdscript/warnings/exclude_addons"

# Mirror of GDScriptParser::WarningDirectoryRule::Decision in
# `modules/gdscript/gdscript_parser.h`. Stable under Godot's compatibility
# policy because the PropertyInfo hint in `gdscript.cpp:2840` exposes
# `Exclude,Include` in this exact order to users.
const DECISION_EXCLUDE := 0


## Returns true when `_enter_tree` should abort plugin load: `inferred_declaration`
## is Warn or Error AND the gdUnit4 addon path is not warning-suppressed.
static func should_block_plugin_load() -> bool:
	var inferred_declaration: int = int(ProjectSettings.get_setting(
			SETTING_INFERRED_DECLARATION, 0))
	if inferred_declaration == 0:
		return false
	return not is_addon_warnings_suppressed()


## Returns true if Godot would suppress warnings for scripts under
## `res://addons/gdUnit4/`. On 4.6+ this walks `directory_rules` mirroring
## the engine. On <4.6 this reads `exclude_addons`.
static func is_addon_warnings_suppressed() -> bool:
	if Engine.get_version_info().hex >= 0x40600:
		return _is_suppressed_by_directory_rules()
	# Godot <4.6: exclude_addons is the only suppression knob.
	return bool(ProjectSettings.get_setting(SETTING_EXCLUDE_ADDONS, true))


## User-facing help message printed alongside the block. Lists the valid
## fixes for the running Godot version. On 4.6+ it does NOT recommend
## `exclude_addons`, which is deprecated (see gdscript_parser.cpp:113-123).
static func build_block_help_message() -> String:
	if Engine.get_version_info().hex >= 0x40600:
		return ("GdUnit4 needs its addon path excluded from warnings. "
				+ "Fix in project.godot [debug]: keep the default "
				+ "directory_rules={\"res://addons\": 0} (already excludes "
				+ "gdUnit4 via prefix match), or add "
				+ "\"res://addons/gdUnit4\": 0 to directory_rules. When "
				+ "overriding directory_rules in project.godot, preserve "
				+ "\"res://addons\": 0 or other addons lose warning "
				+ "suppression too.")
	return ("GdUnit4 needs its addon path excluded from warnings. "
			+ "Fix in project.godot [debug]: set "
			+ "debug/gdscript/warnings/exclude_addons=true.")


# Mirrors the rule pipeline in `GDScriptParser::update_project_settings()`
# (`gdscript_parser.cpp:127-147`) and
# `GDScriptParser::evaluate_warning_directory_rules_for_script_path`
# (`gdscript_parser.cpp:312-328`).
#
# Sort-key note: the engine sorts normalized rules by
# `directory_path.count("/")` descending, and we do the same. For a single
# target path (the gdUnit4 case), matching rules always form a prefix chain,
# so slash count and length order coincide; the distinction only matters when
# evaluating multiple target paths. We use slash count to match the engine
# literally so this comment stays honest if the helper is reused.
static func _is_suppressed_by_directory_rules() -> bool:
	var rules: Dictionary = ProjectSettings.get_setting(
			SETTING_DIRECTORY_RULES, {})
	if rules.is_empty():
		return false
	# Normalize each key the way the engine does (gdscript_parser.cpp:127-139):
	# simplify_path() collapses redundant slashes and . / .. segments, then we
	# append a trailing slash so prefix matching aligns to directory boundaries.
	var normalized_rules: Array[Dictionary] = []
	for key: Variant in rules.keys():
		var dir: String = str(key).simplify_path()
		if not dir.ends_with("/"):
			dir += "/"
		normalized_rules.append({"dir": dir, "decision": int(rules[key])})
	# Sort by slash count, descending (gdscript_parser.cpp:141-147 RuleSort).
	normalized_rules.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return (a["dir"] as String).count("/") > (b["dir"] as String).count("/"))
	# First prefix match wins (gdscript_parser.cpp:312-328).
	for rule: Dictionary in normalized_rules:
		if GDUNIT_ADDON_PATH.begins_with(rule["dir"] as String):
			return (rule["decision"] as int) == DECISION_EXCLUDE
	return false
