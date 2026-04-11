class_name GdUnitPluginGateTest
extends GdUnitTestSuite

# Tests for GdUnitPluginGate (extracted from plugin.gd _enter_tree).
# Source under test: res://addons/gdUnit4/src/core/GdUnitPluginGate.gd

const SETTING_INFERRED := "debug/gdscript/warnings/inferred_declaration"
const SETTING_RULES := "debug/gdscript/warnings/directory_rules"

var _had_inferred: bool
var _original_inferred: Variant
var _had_rules: bool
var _original_rules: Variant


## Suite-level skip: the `directory_rules` branch under test only applies
## to Godot 4.6+. On earlier versions the helper falls through to
## `exclude_addons`, which this suite does not exercise. The framework
## reports these runs as skipped (not silently passing).
func before(
		_do_skip: bool = Engine.get_version_info().hex < 0x40600,
		_skip_reason: String = "GdUnitPluginGate directory_rules branch requires Godot 4.6+"
) -> void:
	pass


func before_test() -> void:
	_had_inferred = ProjectSettings.has_setting(SETTING_INFERRED)
	if _had_inferred:
		_original_inferred = ProjectSettings.get_setting(SETTING_INFERRED)
	_had_rules = ProjectSettings.has_setting(SETTING_RULES)
	if _had_rules:
		_original_rules = ProjectSettings.get_setting(SETTING_RULES)


func after_test() -> void:
	# Only clear settings that existed before the test. Clearing a setting
	# that was never present errors out, which would fail under CI's
	# warnings-as-errors.
	if _had_inferred:
		ProjectSettings.set_setting(SETTING_INFERRED, _original_inferred)
	elif ProjectSettings.has_setting(SETTING_INFERRED):
		ProjectSettings.clear(SETTING_INFERRED)
	if _had_rules:
		ProjectSettings.set_setting(SETTING_RULES, _original_rules)
	elif ProjectSettings.has_setting(SETTING_RULES):
		ProjectSettings.clear(SETTING_RULES)


## Covers the plugin-load gate decision across the full configuration
## matrix. Each row is `(inferred_declaration level, directory_rules value,
## expected block outcome)`. Engine source references for the semantics
## under test: `modules/gdscript/gdscript_parser.cpp:127-139` (rule
## normalization), `:141-147` (`RuleSort`), and `:312-328`
## (`evaluate_warning_directory_rules_for_script_path`).
func test_should_block_plugin_load(
		inferred: int,
		rules: Dictionary,
		expected: bool,
		_test_parameters := [
			# inferred_declaration=0 short-circuits regardless of rules
			[0, {}, false],
			# engine-registered default — every fresh 4.6 project
			[1, {"res://addons": 0}, false],
			# explicit gdUnit4-only rule
			[1, {"res://addons/gdUnit4": 0}, false],
			# both the default and an explicit rule present
			[1, {"res://addons": 0, "res://addons/gdUnit4": 0}, false],
			# trailing-slash key on the gdUnit4 rule
			[1, {"res://addons/gdUnit4/": 0}, false],
			# malformed key with redundant slashes — engine simplifies, so do we
			[1, {"res://addons//gdUnit4": 0}, false],
			# malformed key with `.` segment — engine simplifies, so do we
			[1, {"res://./addons": 0}, false],
			# specific INCLUDE overrides broader EXCLUDE — sort-order coverage
			[1, {"res://addons": 0, "res://addons/gdUnit4": 1}, true],
			# empty rules dict — no suppression anywhere
			[1, {}, true],
			# user explicitly enabled warnings for the addons tree
			[1, {"res://addons": 1}, true],
			# user explicitly enabled warnings for gdUnit4 specifically
			[1, {"res://addons/gdUnit4": 1}, true],
			# rule that doesn't prefix res://addons/gdUnit4/ has no effect
			[1, {"res://src/game": 0}, true],
		]
) -> void:
	ProjectSettings.set_setting(SETTING_INFERRED, inferred)
	ProjectSettings.set_setting(SETTING_RULES, rules)
	assert_bool(GdUnitPluginGate.should_block_plugin_load()).is_equal(expected)


## The help message must not recommend `exclude_addons` on 4.6+ — the
## setting is wrapped in `#ifndef DISABLE_DEPRECATED` at
## `gdscript_parser.cpp:113-123` and `update_project_settings()` clears it
## from ProjectSettings after migrating its value into `directory_rules`.
func test_help_message_omits_exclude_addons_on_46_plus() -> void:
	var msg: String = GdUnitPluginGate.build_block_help_message()
	assert_str(msg).contains("directory_rules")
	assert_str(msg).not_contains("exclude_addons")
