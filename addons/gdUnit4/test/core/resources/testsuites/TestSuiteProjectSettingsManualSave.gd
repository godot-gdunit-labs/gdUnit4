# Inner suite for GdUnitProjectSettingsAutoSaveTest, run with auto save enabled.
# Every before_test() records the setting the test starts from, changes it and takes a manual snapshot,
# which is ignored with an error while auto save is enabled. When the manual snapshot still replaced the snapshot
# restored after every attempt, the next test would start from the value the previous before_test() set.
extends GdUnitTestSuite

const PROBE_KEY := "application/config/name"
const SEEN_META := "gdunit_manual_save_probe_seen"


func before() -> void:
	ProjectSettings.set_setting(PROBE_KEY, "__before_probe__")


func before_test() -> void:
	var seen: Array = Engine.get_meta(SEEN_META, [])
	seen.append(ProjectSettings.get_setting(PROBE_KEY))
	Engine.set_meta(SEEN_META, seen)
	ProjectSettings.set_setting(PROBE_KEY, "__manual_save_probe__")
	snapshot_project_settings()


func test_first() -> void:
	assert_str(str(ProjectSettings.get_setting(PROBE_KEY))).is_equal("__manual_save_probe__")


func test_second() -> void:
	assert_str(str(ProjectSettings.get_setting(PROBE_KEY))).is_equal("__manual_save_probe__")
