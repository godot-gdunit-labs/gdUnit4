extends GdUnitUIAssert

var _base: GdUnitAssertImpl

const CURRENT_SCREENSHOTS_PATH = "{0}/visual_regression/{2}-{1}/{2}_current.png"
const DIFF_SCREENSHOTS_PATH = "{0}/visual_regression/{2}-{1}/{2}_diff.png"
const EXPECTED_SCREENSHOTS_PATH = "{0}/visual_regression/{2}-{1}/{2}_expected.png"

func _init(current: Node) -> void:
	_base = GdUnitAssertImpl.new(current)
	# save the actual assert instance on the current thread context
	GdUnitThreadManager.get_current_context().set_assert(self)


func _notification(event: int) -> void:
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null


func failure_message() -> String:
	return _base.failure_message()


func current_value() -> Node:
	return _base.current_value()


func report_success() -> GdUnitUIAssert:
	_base.report_success()
	return self


func report_error(error: String) -> GdUnitUIAssert:
	_base.report_error(error)
	return self


func override_failure_message(message: String) -> GdUnitUIAssert:
	@warning_ignore("return_value_discarded")
	_base.override_failure_message(message)
	return self


func append_failure_message(message: String) -> GdUnitUIAssert:
	@warning_ignore("return_value_discarded")
	_base.append_failure_message(message)
	return self


func is_null() -> GdUnitUIAssert:
	@warning_ignore("return_value_discarded")
	_base.is_null()
	return self


func is_not_null() -> GdUnitUIAssert:
	@warning_ignore("return_value_discarded")
	_base.is_not_null()
	return self


func is_equal(expected: Variant) -> GdUnitUIAssert:
	var current := current_value()
	if current == null:
		return report_error(GdAssertMessages.error_equal(current, expected))

	if not expected is Node:
		return report_error("Unexpected type <%s> used for argument 'expected'." % GdObjects.typeof_as_string(expected))

	var expected_node: Node = expected

	if expected_node.get_path() != current.get_path():
		return report_error(GdAssertMessages.error_equal(current.get_path(), expected_node.get_path()))
	return report_success()


func is_not_equal(expected: Variant) -> GdUnitUIAssert:
	assert(false, "is_not_equal() is not yet implemented!")
	return self


func is_equal_screenshot(reference_image: Image, config: GdUnitUIConfig = GdUnitUIConfig.strict()) -> GdUnitUIAssert:
	if DisplayServer.get_name() == "headless":
		return report_error("is_equal_screenshot() is not supported on 'headless' mode!")

	if reference_image == null:
		return report_error("Expected argument 'reference_image' is null.")

	var current := current_value()
	if current == null:
		return report_error("The current node is null, not able to take a screenshot.")

	var captured_image := GdUnitUiTools.capture_image(current)
	if captured_image == null:
		return report_error("Can't capture image from node {0}".format([current.get_path()]))

	var result := _compare_images(current, reference_image, captured_image, config)
	if result.has("error_not_match"):
		return report_error(GdAssertMessages.error_is_equal_screen_shot(result))
	elif result.has("error_diff_size"):
		return report_error(GdAssertMessages.error_is_equal_screen_shot_diff_size(result))

	return report_success()



func is_equal_position2D(expected_position: Vector2) -> GdUnitUIAssert:
	assert(false, "is_equal_position2D() is not yet implemented!")
	return self


func is_equal_position3D(expected_position: Vector3) -> GdUnitUIAssert:
	assert(false, "is_equal_position3D() is not yet implemented!")
	return self


func is_visible() -> GdUnitUIAssert:
	assert(false, "is_visible() is not yet implemented!")
	return self


func _compare_images(node: Node, reference_image: Image, actual_image: Image, config: GdUnitUIConfig) -> Dictionary:
	var node_name := node.name.replace("@", "")

	if reference_image.get_size() != actual_image.get_size():
		return {
			"error_diff_size": true,
			"node_name" : node_name,
			"actual_size": actual_image.get_size(),
			"reference_size": reference_image.get_size(),
		}

	var width := reference_image.get_width()
	var height := reference_image.get_height()
	var total_pixels := width * height
	var different_pixels: float = 0.0
	# Track difference positions for cluster analysis
	var difference_positions: Array[Vector2i] = []
	var pixel_differences: Array[float] = []

	# Create diff image for debugging
	var diff_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var no_diff_color := Color(0, 0, 0, 0.1)

	for y in range(height):
		for x in range(width):
			var ref_pixel := reference_image.get_pixel(x, y)
			var actual_pixel := actual_image.get_pixel(x, y)
			var pixel_diff := _calculate_pixel_difference(ref_pixel, actual_pixel, config._ignore_alpha)

			if pixel_diff > config._pixel_tolerance:
				different_pixels += 1
				pixel_differences.append(pixel_diff)
				diff_image.set_pixel(x, y, actual_pixel)
				difference_positions.append(Vector2i(x, y))
			else:
				# Keep original pixel
				diff_image.set_pixel(x, y, no_diff_color)

	var difference_ratio := different_pixels / float(total_pixels)
	var matches := difference_ratio <= config._difference_threshold

	# Save diff image if there are differences
	if not matches:
		# Build image paths for reporting based on session report path
		#var test_session: GdUnitTestSession = Engine.get_meta("GdUnitTestSession")
		var report_path :String = "res://reports"
		report_path = "{0}/{1}_{2}".format([report_path, randi(), GdUnitThreadManager.get_current_context().get_execution_context().get_test_case_name()])
		var difference_image_path := DIFF_SCREENSHOTS_PATH.format([report_path, node.get_instance_id(), node_name])
		var captured_image_path := CURRENT_SCREENSHOTS_PATH.format([report_path, node.get_instance_id(), node_name])
		var reference_image_path := EXPECTED_SCREENSHOTS_PATH.format([report_path, node.get_instance_id(), node_name])
		DirAccess.make_dir_recursive_absolute(difference_image_path.get_base_dir())
		diff_image.save_png(difference_image_path)
		reference_image.save_png(reference_image_path)
		actual_image.save_png(captured_image_path)

		var color_analysis := _analyze_color_differences(pixel_differences)

		return {
			"error_not_match" : true,
			"config": "{0}".format([config._config_name]),
			"config.pixel_tolerance" : config._pixel_tolerance,
			"config.difference_threshold" : config._difference_threshold,
			"config.is_ignore_alpha" : config._ignore_alpha,
			"node_name" : node_name,
			"node_path" : node.get_path(),
			"resolution": reference_image.get_size(),
			"total_pixels": total_pixels,
			"difference_ratio": difference_ratio,
			"difference_threshold": config._difference_threshold,
			"different_pixels": different_pixels,
			"different_pixels_percentage": str((100.0/total_pixels) * different_pixels).substr(0, 4),
			"average_color_distance": str(color_analysis.average_distance).substr(0, 4),
			"max_color_distance": color_analysis.max_distance,
			# image paths
			"reference_image_path": reference_image_path,
			"captured_image_path": captured_image_path,
			"difference_image_path": difference_image_path,
		}

	return {
		"node_name" : node_name,
		"resolution": reference_image.get_size(),
		"total_pixels": total_pixels
	}

func _calculate_pixel_difference(pixel1: Color, pixel2: Color, ignore_alpha: bool) -> float:
	# Calculate euclidean distance between colors
	var r_diff: float = abs(pixel1.r - pixel2.r)
	var g_diff: float = abs(pixel1.g - pixel2.g)
	var b_diff: float = abs(pixel1.b - pixel2.b)
	var a_diff: float = abs(pixel1.a - pixel2.a)
	if ignore_alpha:
		a_diff = 0

	return r_diff + g_diff + b_diff + a_diff

	#return sqrt(r_diff * r_diff + g_diff * g_diff + b_diff * b_diff + a_diff * a_diff) / 2.0


# Analyze color difference statistics
func _analyze_color_differences(pixel_differences: Array[float]) -> Dictionary:
	if pixel_differences.is_empty():
		return {
			"average_distance": 0.0,
			"max_distance": 0.0
		}

	var total_distance := 0.0
	var max_distance := 0.0

	for distance in pixel_differences:
		total_distance += distance
		max_distance = max(max_distance, distance)

	var average_distance := total_distance / pixel_differences.size()

	return {
		"average_distance": average_distance,
		"max_distance": max_distance
	}
