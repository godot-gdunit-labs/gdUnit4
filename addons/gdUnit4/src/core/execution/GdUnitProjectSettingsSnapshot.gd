## Captures and restores all in-memory [ProjectSettings] values around a single
## stage of test execution.[br]
## A [GdUnitExecutionContext] holds at most one snapshot. With "Auto Save Project Settings" enabled the
## stages take two snapshots per test suite, the state before [code]before()[/code] and the state
## [code]before()[/code] leaves behind, which every test case context shares:[br]
## [codeblock]
##   suite context
##   ├─ GdUnitTestSuiteBeforeStage
##   │    ├─ snapshot_project_settings()    snapshot A: settings before before()
##   │    └─ before()
##   ├─ GdUnitTestSuiteExecutionStage
##   │    └─ save()                         snapshot B: settings before() left behind
##   ├─ test case context (one per test case, holds B)
##   │    └─ attempt context (one per retry, inherits B)
##   │         ├─ before_test()
##   │         ├─ test_<name>()
##   │         └─ GdUnitTestCaseAfterStage
##   │              ├─ after_test()
##   │              └─ restore() B          every attempt starts from the same state
##   └─ GdUnitTestSuiteAfterStage
##        ├─ after()
##        └─ restore() A                    the suite leaves no settings behind
## [/codeblock]
## With the setting disabled no snapshot is taken by the stages. A test suite can still call
## [method GdUnitTestSuite.snapshot_project_settings] and [method GdUnitTestSuite.restore_project_settings],
## which save into and restore from the context currently running. A snapshot saved in
## [code]before_test()[/code] lands in the attempt context and is restored by [code]GdUnitTestCaseAfterStage[/code]
## after [code]after_test()[/code], a snapshot saved in [code]before()[/code] lands in the suite context and is
## restored by [code]GdUnitTestSuiteAfterStage[/code] after [code]after()[/code].
class_name GdUnitProjectSettingsSnapshot
extends RefCounted

var _snapshot: Dictionary = {}


func save() -> void:
	_snapshot.clear()
	for property: Dictionary in ProjectSettings.get_property_list():
		var name: String = property["name"]
		if ProjectSettings.has_setting(name):
			var value: Variant = ProjectSettings.get_setting(name)
			@warning_ignore("unsafe_method_access")
			_snapshot[name] = value.duplicate(true) if (value is Dictionary or value is Array) else value


## Restores the saved values and keeps them, so the same state can be restored again.[br]
## A [Dictionary] or [Array] is set back as a deep copy, so a test editing the setting in place
## leaves the saved values unchanged.
func restore() -> void:
	for name: String in _snapshot:
		if not ProjectSettings.has_setting(name):
			continue
		var current: Variant = ProjectSettings.get_setting(name)
		var original: Variant = _snapshot[name]
		if current != original:
			@warning_ignore("unsafe_method_access")
			ProjectSettings.set_setting(name, original.duplicate(true) if (original is Dictionary or original is Array) else original)
