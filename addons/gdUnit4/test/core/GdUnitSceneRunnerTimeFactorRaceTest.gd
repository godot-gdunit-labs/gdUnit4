# GdUnit generated TestSuite
@warning_ignore_start("redundant_await", "unsafe_method_access")
class_name GdUnitSceneRunnerTimeFactorRaceTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit4/src/core/GdUnitSceneRunnerImpl.gd'


func load_test_scene() -> Node:
	@warning_ignore("unsafe_method_access")
	return auto_free(load("res://addons/gdUnit4/test/mocker/resources/scenes/TestScene.tscn").instantiate())


#region time_factor_leaks_across_tests
## Regression test for GD-1300: a corrupted baseline captured by an earlier test's overlapping
## runners used to leak into a later, unrelated test's engine tick rate once the framework's
## end-of-test gc() deactivated each runner on its own (possibly corrupted) saved baseline.
## See also GdUnitSceneRunnerTimeFactorBaselineTest for the underlying baseline-capture defect.
func test_a_leaves_overlapping_runners_active() -> void:
	var runner_a := scene_runner(load_test_scene())
	runner_a.set_time_factor(2)

	var runner_b := scene_runner(load_test_scene())
	runner_b.set_time_factor(3)
	# runners are released by the framework's auto_free gc() at the end of this test,
	# each restoring the engine tick rate to its own saved baseline.


func test_b_sees_a_clean_default_tick_rate() -> void:
	# test_a's overlapping runners must not leave a corrupted saved baseline behind, so the
	# engine tick rate observed here should be the untouched project default.
	assert_int(Engine.get_physics_ticks_per_second()).is_equal(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60))
#endregion
