extends GdUnitTestSuite


const UIConfig = GdUnitUIAssert.GdUnitUIConfig


func test_is_equal_screenshot_strict() -> void:
	var reference_image :CompressedTexture2D = load("res://addons/gdUnit4/test/resources/assets/ycm-gradient.png")
	var node := await create_example_node("res://addons/gdUnit4/test/resources/assets/ycm-gradient.png", reference_image.get_size())

	assert_ui(node).is_equal_screenshot(reference_image.get_image(), UIConfig.strict())


func test_is_equal_screenshot_strict_with_diff() -> void:
	var reference_image :CompressedTexture2D = load("res://addons/gdUnit4/test/resources/assets/ycm-gradient.png")
	var node := await create_example_node("res://addons/gdUnit4/test/resources/assets/ycm-gradient_additions.png", reference_image.get_size())

	assert_ui(node).is_equal_screenshot(reference_image.get_image(), UIConfig.anti_aliasing())


func test_is_equal_screenshot_strict_with_alpha() -> void:
	var reference_image :CompressedTexture2D = load("res://addons/gdUnit4/test/resources/assets/pacman.png")
	var node := await create_example_node("res://addons/gdUnit4/test/resources/assets/pacman.png", reference_image.get_size())


	assert_ui(node).is_equal_screenshot(reference_image.get_image(), UIConfig.strict().ignore_alpha())


func create_example_node(image_path: String, minimum_size: Vector2i) -> Node:
	var node: Control = auto_free(Control.new())
	node.custom_minimum_size = minimum_size
	var trect := TextureRect.new()
	trect.texture = load(image_path)
	node.add_child(trect)
	add_child(node)
	await await_millis(100)
	return node
