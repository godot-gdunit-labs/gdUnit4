# GdUnit generated TestSuite
@warning_ignore_start("redundant_await")
class_name GdUnitSceneRunner3DTest
extends GdUnitTestSuite

const GAME_3D_SCENE := "res://addons/gdUnit4/test/core/resources/scenes/game_3d/Game3DTestScene.tscn"

var _runner: GdUnitSceneRunner


func before_test() -> void:
	_runner = scene_runner(GAME_3D_SCENE)
	await _runner.await_input_processed()


func _screen_position(node_name: String) -> Vector2:
	var node: Node3D = _runner.find_child(node_name)
	return _runner.scene().get_viewport().get_camera_3d().unproject_position(node.global_position)


func _player() -> CharacterBody3D:
	return _runner.find_child("Player")


#region scene setup
func test_scene_uses_own_camera() -> void:
	assert_that(_runner.scene().get_viewport().get_camera_3d()).is_equal(_runner.find_child("Camera3D"))


func test_player_falls_onto_floor() -> void:
	await assert_func(_player(), "is_on_floor").wait_until(2000).is_true()
#endregion


#region keyboard and actions
func test_move_player_by_action() -> void:
	var start_x := _player().position.x

	_runner.simulate_action_press("ui_right")
	await _runner.simulate_frames(10)
	_runner.simulate_action_release("ui_right")

	assert_float(_player().position.x).is_greater(start_x)


func test_jump_player_by_key() -> void:
	await assert_func(_player(), "is_on_floor").wait_until(2000).is_true()

	monitor_signals(_runner.scene(), false)
	_runner.simulate_key_press(KEY_SPACE)
	await assert_signal(_runner.scene()).wait_until(500).is_emitted("jumped")
	_runner.simulate_key_release(KEY_SPACE)

	assert_float(_player().velocity.y).is_greater(0.0)
#endregion


#region mouse picking
func test_hover_target_by_mouse() -> void:
	monitor_signals(_runner.scene(), false)
	_runner.simulate_mouse_move(_screen_position("Target"))

	await assert_signal(_runner.scene()).wait_until(500).is_emitted("target_hovered")


func test_click_target_by_mouse() -> void:
	monitor_signals(_runner.scene(), false)
	_runner.set_mouse_position(_screen_position("Target"))
	_runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	await assert_signal(_runner.scene()).wait_until(500).is_emitted("target_clicked", any_vector3())


func test_click_hud_button_over_3d_scene() -> void:
	var button: Button = _runner.find_child("StartButton")

	monitor_signals(_runner.scene(), false)
	_runner.set_mouse_position(button.get_global_rect().get_center())
	_runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	await assert_signal(_runner.scene()).wait_until(500).is_emitted("start_pressed")
#endregion
