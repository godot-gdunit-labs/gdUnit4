# GdUnit generated TestSuite
class_name GdUnitSceneRunnerRenderingTest
extends GdUnitTestSuite

## Verifies which rendering dependent features work in a scene runner with a display and in headless mode.[br]
## Headless Godot uses a dummy renderer, it does not render anything.

const GREEN_SHADER := """
shader_type canvas_item;

void fragment() {
	COLOR = vec4(0.0, 1.0, 0.0, 1.0);
}
"""


func _is_headless() -> bool:
	return DisplayServer.get_name() == "headless"


func _create_scene_2d() -> Node2D:
	var scene: Node2D = auto_free(Node2D.new())
	var notifier := VisibleOnScreenNotifier2D.new()
	notifier.name = "Notifier"
	notifier.position = Vector2(100, 100)
	scene.add_child(notifier)
	return scene


func _create_scene_3d() -> Node3D:
	var scene: Node3D = auto_free(Node3D.new())
	var camera := Camera3D.new()
	camera.position = Vector3(0, 0, 5)
	scene.add_child(camera)
	var notifier := VisibleOnScreenNotifier3D.new()
	notifier.name = "Notifier"
	scene.add_child(notifier)
	return scene


func _create_shader_scene() -> Control:
	var scene: Control = auto_free(Control.new())
	var shader := Shader.new()
	shader.code = GREEN_SHADER
	var material := ShaderMaterial.new()
	material.shader = shader
	var rect := ColorRect.new()
	rect.color = Color.RED
	rect.size = Vector2(64, 64)
	rect.material = material
	scene.add_child(rect)
	return scene


func test_visible_on_screen_notifier_2d() -> void:
	var scene := _create_scene_2d()
	var notifier: VisibleOnScreenNotifier2D = scene.get_node("Notifier")
	monitor_signals(notifier, false)
	var runner := scene_runner(scene)

	await runner.simulate_frames(5)

	assert_bool(notifier.is_on_screen()).is_equal(not _is_headless())
	if _is_headless():
		await assert_signal(notifier).wait_until(200).is_not_emitted("screen_entered")
	else:
		await assert_signal(notifier).wait_until(200).is_emitted("screen_entered")


func test_visible_on_screen_notifier_3d() -> void:
	var scene := _create_scene_3d()
	var notifier: VisibleOnScreenNotifier3D = scene.get_node("Notifier")
	monitor_signals(notifier, false)
	var runner := scene_runner(scene)

	await runner.simulate_frames(5)

	assert_bool(notifier.is_on_screen()).is_equal(not _is_headless())
	if _is_headless():
		await assert_signal(notifier).wait_until(200).is_not_emitted("screen_entered")
	else:
		await assert_signal(notifier).wait_until(200).is_emitted("screen_entered")


func test_shader_output() -> void:
	var runner := scene_runner(_create_shader_scene())

	await runner.simulate_frames(5)
	if _is_headless():
		assert_str(RenderingServer.get_video_adapter_name()).is_empty()
		return
	await RenderingServer.frame_post_draw

	var image := runner.scene().get_viewport().get_texture().get_image()
	assert_that(image.get_pixel(32, 32)).is_equal(Color.GREEN)
