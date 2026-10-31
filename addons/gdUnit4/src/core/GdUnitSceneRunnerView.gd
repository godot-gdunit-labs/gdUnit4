## Displays the scene runner viewport in the window and draws the simulated mouse cursor on top of it.[br]
## The cursor is drawn on the view only, so it never appears in the scene viewport texture.
class_name GdUnitSceneRunnerView
extends TextureRect

static var _arrow_polygon := PackedVector2Array([
	Vector2(0, 0),
	Vector2(0, 17),
	Vector2(4, 13),
	Vector2(7, 20),
	Vector2(10, 19),
	Vector2(7, 12),
	Vector2(12, 12),
])

var _viewport: SubViewport
var _cursor_image: Texture2D
var _cursor_hotspot := Vector2.ZERO
var _drawn_mouse_position := Vector2.INF
var _drawn_mouse_mode := -1


func _init(viewport: SubViewport) -> void:
	_viewport = viewport
	name = "GdUnitSceneRunnerView"
	texture = viewport.get_texture()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var custom_image: String = ProjectSettings.get_setting("display/mouse_cursor/custom_image", "")
	if not custom_image.is_empty() and ResourceLoader.exists(custom_image):
		_cursor_image = load(custom_image)
		_cursor_hotspot = ProjectSettings.get_setting("display/mouse_cursor/custom_image_hotspot", Vector2.ZERO)


func _process(_delta: float) -> void:
	if needs_redraw():
		queue_redraw()


func _draw() -> void:
	_drawn_mouse_position = _viewport.get_mouse_position()
	_drawn_mouse_mode = Input.mouse_mode
	if not is_cursor_visible(Input.mouse_mode):
		return
	var cursor_position := to_view_position(_drawn_mouse_position)
	if _cursor_image != null:
		draw_texture(_cursor_image, cursor_position - _cursor_hotspot)
		return
	var arrow := Transform2D(0, cursor_position) * _arrow_polygon
	draw_colored_polygon(arrow, Color.WHITE)
	arrow.append(arrow[0])
	draw_polyline(arrow, Color.BLACK)


## The drawn cursor stays on screen until the mouse position or mouse mode changes, a resize redraws the view by itself.
func needs_redraw() -> bool:
	return _viewport.get_mouse_position() != _drawn_mouse_position or Input.mouse_mode != _drawn_mouse_mode


## Maps a position in the scene viewport to the view, where the viewport texture is scaled and centered.
func to_view_position(viewport_position: Vector2) -> Vector2:
	var viewport_size := Vector2(_viewport.size)
	var scale_factor := minf(size.x / viewport_size.x, size.y / viewport_size.y)
	var offset := (size - viewport_size * scale_factor) / 2.0
	return offset + viewport_position * scale_factor


## The cursor is hidden when the scene hides or captures the mouse, e.g. to draw its own cursor node.
static func is_cursor_visible(mouse_mode: Input.MouseMode) -> bool:
	return mouse_mode not in [Input.MOUSE_MODE_HIDDEN, Input.MOUSE_MODE_CONFINED_HIDDEN, Input.MOUSE_MODE_CAPTURED]
