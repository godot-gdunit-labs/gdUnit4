# GdUnit generated TestSuite
class_name GdUnitProjectSettingsAutoSaveTest
extends GdUnitTestSuite

const IGNORE := GdUnitSettings.GdScriptWarningMode.IGNORE
const ERROR := GdUnitSettings.GdScriptWarningMode.ERROR
const MUTATION_SUITE := "res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteProjectSettingsMutation.gd"
const IN_PLACE_SUITE := "res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteProjectSettingsInPlaceEdit.gd"
const RETRY_SUITE := "res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteProjectSettingsRetry.gd"
const MANUAL_SAVE_SUITE := "res://addons/gdUnit4/test/core/resources/testsuites/TestSuiteProjectSettingsManualSave.gd"
const PROBE_KEY := "application/config/name"


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


func test_snapshot_project_settings_pushes_an_error_while_auto_save_enabled() -> void:
	assert_error(func() -> void: snapshot_project_settings()) \
		.is_push_error("'snapshot_project_settings()' has no effect while 'Auto Save Project Settings' is enabled,"
			+ " the project settings are already saved and restored automatically.")


func test_restore_project_settings_pushes_an_error_while_auto_save_enabled() -> void:
	assert_error(func() -> void: restore_project_settings()) \
		.is_push_error("'restore_project_settings()' has no effect while 'Auto Save Project Settings' is enabled,"
			+ " the project settings are already saved and restored automatically.")


func test_snapshot_restore_isolates_setting_change_with_auto_save_disabled() -> void:
	var key := GdUnitSettings.GDSCRIPT_WARNINGS_INFERRED_DECLARATION
	var original: Variant = ProjectSettings.get_setting(key, IGNORE)
	var auto_save: Variant = ProjectSettings.get_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, true)
	ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, false)

	snapshot_project_settings()
	ProjectSettings.set_setting(key, ERROR)
	restore_project_settings()
	ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, auto_save)
	assert_that(ProjectSettings.get_setting(key)).is_equal(original)


#endregion

#region execution stage gating


# Runs a suite through the real executor in an isolated thread context with a chosen
# auto-save flag, so the execution stages decide whether to snapshot the settings.
func run_isolated(tests: Array[GdUnitTestCase], auto_save: bool) -> void:
	await GdUnitThreadManager.run(
		"auto_save_probe_%d" % randi(),
		func() -> void:
			var previous: Variant = ProjectSettings.get_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, true)
			ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, auto_save)
			var executor := GdUnitTestSuiteExecutor.new(true)
			await get_tree().process_frame
			await executor.run_and_wait(tests)
			ProjectSettings.set_setting(GdUnitSettings.TEST_PROJECT_SETTINGS_AUTO_SAVE, previous)
	)


func test_execution_stage_snapshot_is_gated_by_flag() -> void:
	var loaded := GdUnitTestResourceLoader.load_tests(MUTATION_SUITE)
	var tests: Array[GdUnitTestCase] = Array(loaded.values(), TYPE_OBJECT, "RefCounted", GdUnitTestCase)
	var original: Variant = ProjectSettings.get_setting(PROBE_KEY)

	# auto save on: the stage snapshots around the test, so the mutation is rolled back
	await run_isolated(tests, true)
	assert_str(str(ProjectSettings.get_setting(PROBE_KEY))).is_equal(str(original))

	# auto save off: the stage skips the snapshot, so the mutation leaks past the run
	await run_isolated(tests, false)
	assert_str(str(ProjectSettings.get_setting(PROBE_KEY))).is_equal("__auto_save_probe__")

	# clean up the mutation that leaked from the off run
	ProjectSettings.set_setting(PROBE_KEY, original)


func test_execution_stage_restores_in_place_edits_of_every_test() -> void:
	var loaded := GdUnitTestResourceLoader.load_tests(IN_PLACE_SUITE)
	var tests: Array[GdUnitTestCase] = Array(loaded.values(), TYPE_OBJECT, "RefCounted", GdUnitTestCase)
	var original: Dictionary = (ProjectSettings.get_setting(GdUnitSettings.GDSCRIPT_WARNINGS_DIRECTORY_RULES) as Dictionary).duplicate()

	await run_isolated(tests, true)
	# every test of the suite started from the setting as it was before the suite ran
	assert_dict(Engine.get_meta("gdunit_in_place_probe_seen", {})).is_equal({
		"test_edits_setting_in_place_first": original,
		"test_edits_setting_in_place_second": original,
		"test_edits_setting_in_place_third": original,
	})
	assert_dict(ProjectSettings.get_setting(GdUnitSettings.GDSCRIPT_WARNINGS_DIRECTORY_RULES)).is_equal(original)

	Engine.remove_meta("gdunit_in_place_probe_seen")
	# clean up, should an edit have leaked
	ProjectSettings.set_setting(GdUnitSettings.GDSCRIPT_WARNINGS_DIRECTORY_RULES, original)


func test_execution_stage_restores_the_suite_settings_before_every_retry() -> void:
	var loaded := GdUnitTestResourceLoader.load_tests(RETRY_SUITE)
	var tests: Array[GdUnitTestCase] = Array(loaded.values(), TYPE_OBJECT, "RefCounted", GdUnitTestCase)
	var original: Variant = ProjectSettings.get_setting(PROBE_KEY)
	var flaky_check: Variant = ProjectSettings.get_setting(GdUnitSettings.TEST_FLAKY_CHECK, false)

	ProjectSettings.set_setting(GdUnitSettings.TEST_FLAKY_CHECK, true)
	await run_isolated(tests, true)
	ProjectSettings.set_setting(GdUnitSettings.TEST_FLAKY_CHECK, flaky_check)
	# each retry started from the settings before() left behind, not from the failed attempt's
	assert_dict(Engine.get_meta("gdunit_retry_probe_seen", {}))\
		.is_equal({ "single": "__before_probe__", "fuzzed": "__before_probe__" })
	assert_str(str(ProjectSettings.get_setting(PROBE_KEY))).is_equal(str(original))

	Engine.remove_meta("gdunit_retry_probe_seen")
	# clean up, should a change have leaked
	ProjectSettings.set_setting(PROBE_KEY, original)


func test_execution_stage_keeps_the_suite_settings_on_a_rejected_manual_snapshot() -> void:
	var loaded := GdUnitTestResourceLoader.load_tests(MANUAL_SAVE_SUITE)
	var tests: Array[GdUnitTestCase] = Array(loaded.values(), TYPE_OBJECT, "RefCounted", GdUnitTestCase)
	var original: Variant = ProjectSettings.get_setting(PROBE_KEY)

	await run_isolated(tests, true)
	# the manual snapshot in before_test() is rejected and never changes the settings the next test starts from
	assert_array(Engine.get_meta("gdunit_manual_save_probe_seen", [])).is_equal(["__before_probe__", "__before_probe__"])
	assert_str(str(ProjectSettings.get_setting(PROBE_KEY))).is_equal(str(original))

	Engine.remove_meta("gdunit_manual_save_probe_seen")
	# clean up, should a change have leaked
	ProjectSettings.set_setting(PROBE_KEY, original)

#endregion
