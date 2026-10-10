class_name GdUnitFontsTest
extends GdUnitTestSuite


const __source = 'res://addons/gdUnit4/src/ui/GdUnitFonts.gd'


class TestEditorSettings:
	var _values: Dictionary

	func _init(values: Dictionary) -> void:
		_values = values

	func has_setting(name: String) -> bool:
		return _values.has(name)

	func get_setting(name: String) -> Variant:
		return _values.get(name)


#region _main_font_size
func test_main_font_size_reads_the_renamed_setting() -> void:
	var settings := TestEditorSettings.new({"interface/editor/fonts/main_font_size": 18})

	assert_float(GdUnitFonts._main_font_size(settings)).is_equal(18.0)


func test_main_font_size_falls_back_to_the_name_before_godot_4_7() -> void:
	var settings := TestEditorSettings.new({"interface/editor/main_font_size": 14})

	assert_float(GdUnitFonts._main_font_size(settings)).is_equal(14.0)
#endregion
