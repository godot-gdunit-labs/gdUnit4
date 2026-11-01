# GdUnit generated TestSuite
class_name GdUnitSceneRunnerViewTest
extends GdUnitTestSuite

const CURSOR_IMAGE := "res://addons/gdUnit4/test/core/resources/scenes/icon.png"


func _create_view(view_size: Vector2) -> GdUnitSceneRunnerView:
	var viewport: SubViewport = auto_free(SubViewport.new())
	viewport.size = Vector2i(1152, 648)
	var view: GdUnitSceneRunnerView = auto_free(GdUnitSceneRunnerView.new(viewport))
	view.set_anchors_preset(Control.PRESET_TOP_LEFT)
	view.size = view_size
	return view


#region to_view_position
func test_to_view_position_same_size() -> void:
	var view := _create_view(Vector2(1152, 648))

	assert_vector(view.to_view_position(Vector2(100, 50))).is_equal(Vector2(100, 50))


func test_to_view_position_scaled() -> void:
	var view := _create_view(Vector2(576, 324))

	assert_vector(view.to_view_position(Vector2(100, 50))).is_equal(Vector2(50, 25))


func test_to_view_position_centered() -> void:
	var view := _create_view(Vector2(1152, 748))

	assert_vector(view.to_view_position(Vector2(100, 50))).is_equal(Vector2(100, 100))
#endregion


#region needs_redraw
func test_needs_redraw_before_first_draw() -> void:
	var view := _create_view(Vector2(1152, 648))

	assert_bool(view.needs_redraw()).is_true()


func test_needs_redraw_unchanged() -> void:
	var view := _create_view(Vector2(1152, 648))
	view._drawn_mouse_position = view._viewport.get_mouse_position()
	view._drawn_mouse_mode = Input.mouse_mode

	assert_bool(view.needs_redraw()).is_false()


func test_needs_redraw_on_mouse_move() -> void:
	var view := _create_view(Vector2(1152, 648))
	add_child(view._viewport)
	view._drawn_mouse_position = view._viewport.get_mouse_position()
	view._drawn_mouse_mode = Input.mouse_mode

	var event := InputEventMouseMotion.new()
	event.position = view._drawn_mouse_position + Vector2(10, 10)
	view._viewport.push_input(event)

	assert_bool(view.needs_redraw()).is_true()


func test_needs_redraw_on_mouse_mode_change() -> void:
	var view := _create_view(Vector2(1152, 648))
	view._drawn_mouse_position = view._viewport.get_mouse_position()
	view._drawn_mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE

	assert_bool(view.needs_redraw()).is_true()
#endregion


#region is_cursor_visible
func test_is_cursor_visible() -> void:
	assert_bool(GdUnitSceneRunnerView.is_cursor_visible(Input.MOUSE_MODE_VISIBLE)).is_true()
	assert_bool(GdUnitSceneRunnerView.is_cursor_visible(Input.MOUSE_MODE_CONFINED)).is_true()


func test_is_cursor_visible_hidden_or_captured() -> void:
	assert_bool(GdUnitSceneRunnerView.is_cursor_visible(Input.MOUSE_MODE_HIDDEN)).is_false()
	assert_bool(GdUnitSceneRunnerView.is_cursor_visible(Input.MOUSE_MODE_CONFINED_HIDDEN)).is_false()
	assert_bool(GdUnitSceneRunnerView.is_cursor_visible(Input.MOUSE_MODE_CAPTURED)).is_false()
#endregion


#region cursor image
func test_cursor_image_default() -> void:
	var view := _create_view(Vector2(1152, 648))

	assert_object(view._cursor_image).is_null()
	assert_vector(view._cursor_hotspot).is_equal(Vector2.ZERO)


func test_cursor_image_from_project_settings() -> void:
	ProjectSettings.set_setting("display/mouse_cursor/custom_image", CURSOR_IMAGE)
	ProjectSettings.set_setting("display/mouse_cursor/custom_image_hotspot", Vector2(4, 6))

	var view := _create_view(Vector2(1152, 648))

	assert_object(view._cursor_image).is_equal(load(CURSOR_IMAGE))
	assert_vector(view._cursor_hotspot).is_equal(Vector2(4, 6))
#endregion
