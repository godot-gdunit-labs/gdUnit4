# GdUnit generated TestSuite
@warning_ignore_start("redundant_await")
class_name GdUnitSceneRunnerRenderingE2ETest
extends GdUnitTestSuite
## End-to-end tests that need rendered output, they only pass with a display and run in their own CI job.

const GREEN_SHADER := """
shader_type canvas_item;

void fragment() {
	COLOR = vec4(0.0, 1.0, 0.0, 1.0);
}
"""


func test_shader_output() -> void:
	var shader := Shader.new()
	shader.code = GREEN_SHADER
	var material := ShaderMaterial.new()
	material.shader = shader
	var rect: ColorRect = auto_free(ColorRect.new())
	rect.color = Color.RED
	rect.size = Vector2(64, 64)
	rect.material = material
	var runner := scene_runner(rect)

	await runner.simulate_frames(5)
	await RenderingServer.frame_post_draw

	var image := runner.scene().get_viewport().get_texture().get_image()
	assert_that(image.get_pixel(32, 32)).is_equal(Color.GREEN)


func test_visible_on_screen_notifier() -> void:
	var scene: Node2D = auto_free(Node2D.new())
	var notifier := VisibleOnScreenNotifier2D.new()
	notifier.position = Vector2(100, 100)
	scene.add_child(notifier)
	var runner := scene_runner(scene)

	await runner.simulate_frames(5)

	assert_bool(notifier.is_on_screen()).is_true()


func test_screen_capture() -> void:
	var scene: Control = auto_free(Control.new())
	var rect := ColorRect.new()
	rect.color = Color.BLUE
	rect.position = Vector2(100, 100)
	rect.size = Vector2(200, 100)
	scene.add_child(rect)
	var runner := scene_runner(scene)
	runner.set_mouse_position(Vector2(150, 150))

	await runner.simulate_frames(5)
	await RenderingServer.frame_post_draw

	var capture_file := create_temp_dir("screen_capture").path_join("capture.png")
	assert_int(runner.scene().get_viewport().get_texture().get_image().save_png(capture_file)).is_equal(OK)
	var capture := Image.load_from_file(capture_file)
	@warning_ignore("unsafe_call_argument")
	assert_that(capture.get_size()).is_equal(Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	))
	assert_that(capture.get_pixel(250, 180)).is_equal(Color.BLUE)
	# the simulated mouse cursor is drawn on the window only, the capture shows the scene below it
	assert_that(capture.get_pixel(152, 160)).is_equal(Color.BLUE)
@warning_ignore_restore("redundant_await")
