# Inner suite for GdUnitProjectSettingsAutoSaveTest, run with the flaky check enabled.
# The first attempt of each test changes a setting and fails, so the test runs again. The second
# attempt records what the setting holds when it starts:
#   restored after every attempt          -> the value before() set
#   restored around the whole test case   -> the value the failed attempt set
extends GdUnitTestSuite

const PROBE_KEY := "application/config/name"
const SEEN_META := "gdunit_retry_probe_seen"

var _attempts := {}


func before() -> void:
	ProjectSettings.set_setting(PROBE_KEY, "__before_probe__")


func test_changes_setting_and_fails_once() -> void:
	_attempt("single")


func test_fuzzed_changes_setting_and_fails_once(fuzzer := Fuzzers.rangei(0, 9), fuzzer_iterations := 1) -> void:
	assert_int(fuzzer.next_value()).is_between(0, 9)
	_attempt("fuzzed")


func _attempt(test_name: String) -> void:
	_attempts[test_name] = _attempts.get(test_name, 0) + 1
	if _attempts[test_name] == 1:
		ProjectSettings.set_setting(PROBE_KEY, "__failed_attempt_probe__")
		assert_bool(false).override_failure_message("fails the first attempt").is_true()
		return
	var seen: Dictionary = Engine.get_meta(SEEN_META, {})
	seen[test_name] = ProjectSettings.get_setting(PROBE_KEY)
	Engine.set_meta(SEEN_META, seen)
