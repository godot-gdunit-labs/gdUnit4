## GdUnitUIAssert provides assertions for UI and visual testing of Godot nodes.[br]
## [br]
## This class extends GdUnitAssert to offer specialized testing capabilities for user interfaces,[br]
## including screenshot comparison, layout validation, positioning checks, and visibility testing.[br]
## [br]
## [color=yellow][i]Use this class through the assert_ui() function for fluent assertion syntax[/i][/color][br]
## [br]
## Common usage patterns:[br]
## - Screenshot regression testing with configurable tolerances[br]
## - Layout validation for size and positioning[br]
## - Visibility state verification[br]
## - Cross-platform UI consistency testing[br]
## [br]
## [b]Example:[/b] Basic screenshot testing[br]
## [codeblock]
## func test_button_appearance():
##     var button = scene.get_node("Button")
##     var expected_image = load("res://test/screenshots/button_normal.png")
##     assert_ui(button).is_equal_screenshot(expected_image, GdUnitUIConfig.ui_testing())
## [/codeblock]
## [br]
## [b]Example:[/b] Layout validation[br]
## [codeblock]
## func test_dialog_layout():
##     var dialog = scene.get_node("Dialog")
##     assert_ui(dialog).is_equal_size(Vector2i(400, 300))
##     assert_ui(dialog).is_visible()
## [/codeblock]
class_name GdUnitUIAssert
extends GdUnitAssert


## Configuration class for UI assertion parameters.[br]
## [br]
## GdUnitUIConfig provides a fluent API for configuring visual comparison tolerances,[br]
## cropping regions, and other parameters used in UI testing assertions.[br]
## [br]
## [color=yellow][i]Use the static factory methods for common configurations or build custom ones with the fluent API[/i][/color][br]
## [br]
## Configuration options:[br]
## - Pixel-level tolerance for color differences[br]
## - Overall image difference thresholds[br]
## - Alpha channel handling[br]
## - Region cropping for partial comparisons[br]
## - Diff image generation control[br]
## [br]
## [b]Example:[/b] Using preset configurations[br]
## [codeblock]
## # Exact match (default)
## var strict_config = GdUnitUIConfig.strict()
##
## # Allow small differences for anti-aliasing
## var aa_config = GdUnitUIConfig.anti_aliasing()
## [/codeblock]
## [br]
## [b]Example:[/b] Building custom configuration[br]
## [codeblock]
## var custom_config = GdUnitUIConfig.of()
##     .pixel_tolerance(0.02)
##     .difference_threshold(0.05)
##     .ignore_alpha(true)
## [/codeblock]
class GdUnitUIConfig extends RefCounted:
	var _config_name: String
	var _pixel_tolerance: float = 0.0        ## Tolerance for individual pixel differences (0.0 = exact match, 1.0 = any difference allowed)
	var _difference_threshold: float = 0.0   ## Threshold for overall image differences (0.0 = no different pixels, 1.0 = all pixels can differ)
	var _ignore_alpha: bool = false          ## Whether to ignore alpha channel differences
	var _save_diff_image: bool = true        ## Whether to save difference images on test failure

	func _init(name :String) -> void:
		_config_name = name


	## Creates a new GdUnitUIConfig instance with default values.[br]
	## [br]
	## [color=yellow][i]This is the base factory method for building custom configurations[/i][/color][br]
	## [br]
	## Default values:[br]
	## - pixel_tolerance: 0.0 (exact pixel match required)[br]
	## - difference_threshold: 0.0 (no different pixels allowed)[br]
	## - ignore_alpha: false (alpha channel differences matter)[br]
	## - crop_region: empty (compare full images)[br]
	## - save_diff_image: true (generate diff images on failure)[br]
	## [br]
	## [b]return:[/b] A new GdUnitUIConfig instance with default strict settings
	static func of(name :String = "custom") -> GdUnitUIConfig:
		return GdUnitUIConfig.new(name)


	## Sets the tolerance for individual pixel differences.[br]
	## [br]
	## Controls how much individual pixels can differ before being considered "different".[br]
	## Uses euclidean distance between RGBA color values for comparison.[br]
	## [br]
	## [color=yellow][i]Higher values allow more color variation per pixel[/i][/color][br]
	## [br]
	## Tolerance guidelines:[br]
	## - 0.0: Exact color match required[br]
	## - 0.01-0.02: Very strict, good for pixel-perfect UI[br]
	## - 0.03-0.05: Moderate, handles anti-aliasing differences[br]
	## - 0.1+: Lenient, allows significant color variations[br]
	## [br]
	## [param tolerance] Tolerance value between 0.0 (exact match) and 1.0 (any difference allowed)[br]
	## [b]return:[/b] This config instance for method chaining
	func pixel_tolerance(tolerance: float) -> GdUnitUIConfig:
		_pixel_tolerance = clamp(tolerance, 0.0, 1.0)
		return self


	## Sets the threshold for overall image differences.[br]
	## [br]
	## Controls what percentage of pixels can be "different" before the comparison fails.[br]
	## Works in combination with pixel_tolerance to determine overall image matching.[br]
	## [br]
	## [color=yellow][i]This is the final gate - even if pixels pass pixel_tolerance, too many different pixels will fail the test[/i][/color][br]
	## [br]
	## Threshold guidelines:[br]
	## - 0.0: No different pixels allowed[br]
	## - 0.01-0.05: Very strict overall matching[br]
	## - 0.05-0.1: Moderate, good for UI components[br]
	## - 0.1+: Lenient, allows significant image differences[br]
	## [br]
	## [param threshold] Threshold value between 0.0 (no different pixels) and 1.0 (all pixels can differ)[br]
	## [b]return:[/b] This config instance for method chaining
	func difference_threshold(threshold: float) -> GdUnitUIConfig:
		_difference_threshold = clamp(threshold, 0.0, 1.0)
		return self


	## Configures whether to ignore alpha channel differences.[br]
	## [br]
	## When enabled, only RGB values are compared, ignoring transparency differences.[br]
	## Useful when testing elements that may have slight transparency variations.[br]
	## [br]
	## [color=yellow][i]Enable this when alpha differences are not important for your test case[/i][/color][br]
	## [br]
	## Use cases:[br]
	## - Testing UI elements with animated transparency[br]
	## - Comparing images with different alpha channels[br]
	## - Focusing on color content rather than transparency[br]
	## - Cross-platform testing where alpha rendering varies[br]
	## [br]
	## [b]return:[/b] This config instance for method chaining
	func ignore_alpha() -> GdUnitUIConfig:
		_ignore_alpha = true
		return self


	## Configures whether to save difference images on test failure.[br]
	## [br]
	## When enabled, creates a visual diff image highlighting differences between[br]
	## expected and actual screenshots, useful for debugging test failures.[br]
	## [br]
	## [color=yellow][i]Disable this in CI environments or when running many visual tests to save disk space[/i][/color][br]
	## [br]
	## Benefits when enabled:[br]
	## - Visual debugging of test failures[br]
	## - Quick identification of rendering differences[br]
	## - Historical record of visual changes[br]
	## - Easier test maintenance and updates[br]
	## [br]
	## [param save] Whether to save difference images on test failure[br]
	## [b]return:[/b] This config instance for method chaining
	func save_diff_image(save: bool = true) -> GdUnitUIConfig:
		_save_diff_image = save
		return self


	## Creates a strict configuration requiring exact pixel-perfect matching.[br]
	## [br]
	## Equivalent to pixel_tolerance(0.0) and difference_threshold(0.0).[br]
	## Use when you need exact visual matches without any tolerance.[br]
	## [br]
	## [color=yellow][i]Best for pixel-perfect UI testing and reference image validation[/i][/color][br]
	## [br]
	## Recommended for:[br]
	## - Icon and sprite testing[br]
	## - Pixel-perfect UI layouts[br]
	## - Reference image validation[br]
	## - High-precision visual regression testing[br]
	## [br]
	## [b]return:[/b] A strict GdUnitUIConfig instance with zero tolerance
	static func strict() -> GdUnitUIConfig:
		return GdUnitUIConfig.of("strict")  # 0.0/0.0 = exact match


	## Creates a lenient configuration allowing significant visual differences.[br]
	## [br]
	## Allows 5% pixel color differences and up to 10% of pixels to differ.[br]
	## Useful for testing dynamic content or animations where exact matching isn't feasible.[br]
	## [br]
	## [color=yellow][i]Use for testing dynamic content, animations, or when minor visual differences are acceptable[/i][/color][br]
	## [br]
	## Recommended for:[br]
	## - Animated UI elements[br]
	## - Dynamic content that changes between runs[br]
	## - Cross-platform testing with rendering variations[br]
	## - Testing where perfect matching is not critical[br]
	## [br]
	## [b]return:[/b] A lenient GdUnitUIConfig instance (5% pixel tolerance, 10% difference threshold)
	static func lenient() -> GdUnitUIConfig:
		return GdUnitUIConfig.of("lenient").pixel_tolerance(0.05).difference_threshold(0.1)


	## Creates a configuration optimized for UI component testing.[br]
	## [br]
	## Allows 2% pixel color differences and up to 5% of pixels to differ.[br]
	## Good balance for testing UI elements that may have minor rendering variations.[br]
	## [br]
	## [color=yellow][i]This is the recommended starting point for most UI component testing[/i][/color][br]
	## [br]
	## Recommended for:[br]
	## - Button and control testing[br]
	## - Dialog and panel validation[br]
	## - Form and layout testing[br]
	## - General UI component regression testing[br]
	## [br]
	## [b]return:[/b] A UI testing optimized GdUnitUIConfig instance (2% pixel tolerance, 5% difference threshold)
	static func ui_testing() -> GdUnitUIConfig:
		return GdUnitUIConfig.of("ui_testing").pixel_tolerance(0.02).difference_threshold(0.05)


	## Creates a configuration that handles anti-aliasing differences.[br]
	## [br]
	## Allows 3% pixel color differences but only 2% of pixels can differ overall.[br]
	## Designed for content with anti-aliased edges that may render slightly differently.[br]
	## [br]
	## [color=yellow][i]Use when testing content with smooth edges, fonts, or anti-aliased graphics[/i][/color][br]
	## [br]
	## Recommended for:[br]
	## - Text and font rendering[br]
	## - Smooth graphics and curves[br]
	## - Anti-aliased UI elements[br]
	## - Vector graphics and scalable content[br]
	## [br]
	## [b]return:[/b] An anti-aliasing tolerant GdUnitUIConfig instance (3% pixel tolerance, 2% difference threshold)
	static func anti_aliasing() -> GdUnitUIConfig:
		return GdUnitUIConfig.of("anti_aliasing").pixel_tolerance(0.03).difference_threshold(0.02)


## Asserts that the node's screenshot matches the expected image.[br]
## [br]
## Takes a screenshot of the source node and compares it pixel-by-pixel with the expected image.[br]
## The comparison behavior is controlled by the provided configuration.[br]
## [br]
## [color=yellow][i]This is the primary method for visual regression testing[/i][/color][br]
## [br]
## Comparison process:[br]
## - Captures current state of the node as an image[br]
## - Applies any configured cropping or preprocessing[br]
## - Compares each pixel using the specified tolerances[br]
## - Generates diff images if enabled and test fails[br]
## [br]
## [param expected] The expected image to compare against[br]
## [param config] Configuration for the comparison (default is strict mode)[br]
## [b]return:[/b] This assert instance for method chaining[br]
## [br]
## [b]Example:[/b] Basic screenshot comparison[br]
## [codeblock]
## var expected = load("res://test/screenshots/button.png")
## assert_ui(button).is_equal_screenshot(expected, GdUnitUIConfig.ui_testing())
## [/codeblock]
@warning_ignore("unused_parameter")
func is_equal_screenshot(expected: Image, config: GdUnitUIConfig = GdUnitUIConfig.strict()) -> GdUnitUIAssert:
	@warning_ignore("assert_always_true")
	assert(true, "'is_equal_screenshot' is not implemented!")
	return self


## Asserts that the 2D node is at the expected position.[br]
## [br]
## Checks the global_position of 2D nodes (Control, Node2D and their subclasses).[br]
## For 3D nodes, use is_equal_position3D() instead.[br]
## [br]
## [color=yellow][i]Uses global_position for accurate screen positioning regardless of parent transforms[/i][/color][br]
## [br]
## Supported node types:[br]
## - Control: Uses global_position[br]
## - Node2D: Uses global_position[br]
## - CanvasItem subclasses: Uses global_position[br]
## - Automatically handles parent transformations[br]
## [br]
## [param expected_position] The expected 2D position in global coordinates[br]
## [b]return:[/b] This assert instance for method chaining[br]
## [br]
## [b]Example:[/b] Button position validation[br]
## [codeblock]
## assert_ui(button).is_equal_position2D(Vector2(100, 50))
## [/codeblock]
@warning_ignore("unused_parameter")
func is_equal_position2D(expected_position: Vector2) -> GdUnitUIAssert:
	@warning_ignore("assert_always_true")
	assert(true, "'is_equal_position2D' is not implemented!")
	return self


## Asserts that the 3D node is at the expected position.[br]
## [br]
## Checks the global_position of 3D nodes (Node3D and subclasses).[br]
## For 2D nodes, use is_equal_position2D() instead.[br]
## [br]
## [color=yellow][i]Uses global_position for accurate world positioning regardless of parent transforms[/i][/color][br]
## [br]
## Supported node types:[br]
## - Node3D: Uses global_position[br]
## - MeshInstance3D: Uses global_position[br]
## - CharacterBody3D: Uses global_position[br]
## - All Node3D subclasses: Uses global_position[br]
## [br]
## [param expected_position] The expected 3D position in global coordinates[br]
## [b]return:[/b] This assert instance for method chaining[br]
## [br]
## [b]Example:[/b] Player model position validation[br]
## [codeblock]
## assert_ui(player_model).is_equal_position3D(Vector3(0, 5, 10))
## [/codeblock]
@warning_ignore("unused_parameter")
func is_equal_position3D(expected_position: Vector3) -> GdUnitUIAssert:
	@warning_ignore("assert_always_true")
	assert(true, "'is_equal_position3D' is not implemented!")
	return self


## Asserts that the node is visible.[br]
## [br]
## Checks visibility depending on node type using appropriate visibility methods.[br]
## Considers both the node's visibility state and its visibility in the scene tree.[br]
## [br]
## [color=yellow][i]Visibility checking varies by node type and considers the full scene tree hierarchy[/i][/color][br]
## [br]
## Visibility checks by node type:[br]
## - Control nodes: Uses is_visible_in_tree()[br]
## - CanvasItem nodes: Uses is_visible_in_tree()[br]
## - Node3D nodes: Uses is_visible_in_tree() and checks visibility flags[br]
## - Considers parent visibility and scene tree state[br]
## [br]
## [b]return:[/b] This assert instance for method chaining[br]
## [br]
## [b]Example:[/b] Popup dialog visibility[br]
## [codeblock]
## assert_ui(popup_dialog).is_visible()
## [/codeblock]
func is_visible() -> GdUnitUIAssert:
	@warning_ignore("assert_always_true")
	assert(true, "'is_visible' is not implemented!")
	return self
