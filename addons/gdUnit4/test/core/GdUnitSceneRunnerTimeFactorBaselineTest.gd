# GdUnit generated TestSuite
@warning_ignore_start("redundant_await", "unsafe_method_access")
class_name GdUnitSceneRunnerTimeFactorBaselineTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit4/src/core/GdUnitSceneRunnerImpl.gd'


func load_test_scene() -> Node:
	@warning_ignore("unsafe_method_access")
	return auto_free(load("res://addons/gdUnit4/test/mocker/resources/scenes/TestScene.tscn").instantiate())


#region time_factor_baseline_corruption
## Regression test for GD-1299: GdUnitSceneRunnerImpl used to capture its "restore" baseline
## from the engine's CURRENT physics tick rate at construction time, instead of a true,
## untouched baseline. When a second runner was created while an earlier runner's time factor
## was still active, the second runner's baseline was already scaled, so its own
## set_time_factor() call landed on the wrong tick rate.
func test_overlapping_scene_runners_corrupt_time_factor() -> void:
	var original_tps := Engine.get_physics_ticks_per_second()

	var runner_a := scene_runner(load_test_scene())
	runner_a.set_time_factor(2)

	var runner_b := scene_runner(load_test_scene())
	runner_b.set_time_factor(3)

	# runner_b's baseline must reflect the true, untouched tick rate, not runner_a's still-active
	# 2x factor, otherwise set_time_factor(3) would compound on top of it.
	assert_int(Engine.get_physics_ticks_per_second()).is_equal(int(original_tps * 3))

	Engine.set_physics_ticks_per_second(original_tps)
#endregion
