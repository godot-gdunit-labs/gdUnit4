## The test case shutdown hook implementation.[br]
## It executes the 'test_after()' block from the test-suite.
class_name GdUnitTestCaseAfterStage
extends IGdUnitExecutionStage


## The test-case scoped context (the one the test body executed in), gc'ed right after
## `after_test()` runs and before the parent's own orphan snapshot, so cleanup performed by
## `after_test()` is accounted for and test-case-scoped `auto_free()` objects don't leak into
## the parent context's orphan count.
var test_case_context: GdUnitExecutionContext = null

var _call_stage: bool


func _init(call_stage := true) -> void:
	_call_stage = call_stage


func _execute(context: GdUnitExecutionContext) -> void:
	var test_suite := context.test_suite

	if _call_stage:
		@warning_ignore("redundant_await")
		await test_suite.after_test()

	if test_case_context != null:
		await test_case_context.gc(GdUnitExecutionContext.GC_ORPHANS_CHECK.TEST_CASE)
		test_case_context = null

	await context.gc(GdUnitExecutionContext.GC_ORPHANS_CHECK.TEST_HOOK_AFTER)
	context.error_monitor_stop()
