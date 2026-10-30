# Inner suite for GdUnitProjectSettingsAutoSaveTest.
# Every test records the dictionary setting it starts from, then edits it in place, without
# set_setting. Each test starts from the settings the suite saved after before(), restored after
# the test before it. When the restore sets back the saved values themselves instead of copies,
# the second test edits the saved values, so in any order the third test sees that edit.
extends GdUnitTestSuite

const SEEN_META := "gdunit_in_place_probe_seen"


func test_edits_setting_in_place_first() -> void:
	_record_and_edit("test_edits_setting_in_place_first", "res://__in_place_probe_a__")


func test_edits_setting_in_place_second() -> void:
	_record_and_edit("test_edits_setting_in_place_second", "res://__in_place_probe_b__")


func test_edits_setting_in_place_third() -> void:
	_record_and_edit("test_edits_setting_in_place_third", "res://__in_place_probe_c__")


func _record_and_edit(test_name: String, probe_path: String) -> void:
	var rules: Dictionary = ProjectSettings.get_setting(GdUnitSettings.GDSCRIPT_WARNINGS_DIRECTORY_RULES)
	var seen: Dictionary = Engine.get_meta(SEEN_META, {})
	seen[test_name] = rules.duplicate()
	Engine.set_meta(SEEN_META, seen)
	rules[probe_path] = GdUnitSettings.GdScriptWarningDirectoryMode.INCLUDE
	assert_dict(rules).contains_keys([probe_path])
