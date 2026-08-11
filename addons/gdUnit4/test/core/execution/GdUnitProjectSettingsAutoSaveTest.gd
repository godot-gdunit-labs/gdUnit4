# GdUnit generated TestSuite
class_name GdUnitProjectSettingsAutoSaveTest
extends GdUnitTestSuite


const __source = "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

const IGNORE := GdUnitSettings.GdScriptWarningMode.IGNORE
const ERROR := GdUnitSettings.GdScriptWarningMode.ERROR


#region auto save flag

func test_is_project_settings_auto_save_defaults_true() -> void:
	assert_bool(GdUnitSettings.is_project_settings_auto_save()).is_true()


func test_is_project_settings_auto_save_reflects_disabled_flag() -> void:
	var original: Variant = ProjectSettings.get_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, true)
	ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, false)
	assert_bool(GdUnitSettings.is_project_settings_auto_save()).is_false()
	# restore the flag so the change never leaves this test
	ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, original)

#endregion

#region explicit save / restore

func test_save_restore_isolates_setting_change() -> void:
	var key := GdUnitSettings.GDSCRIPT_WARNINGS_INFERRED_DECLARATION
	var original: Variant = ProjectSettings.get_setting(key, IGNORE)
	# snapshot, mutate, restore — the mutation must not survive restore
	save_project_settings()
	ProjectSettings.set_setting(key, ERROR)
	restore_project_settings()
	assert_that(ProjectSettings.get_setting(key)).is_equal(original)

#endregion
