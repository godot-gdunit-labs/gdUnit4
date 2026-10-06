class_name GdAssertMessagesTest
extends GdUnitTestSuite


const __source = 'res://addons/gdUnit4/src/asserts/GdAssertMessages.gd'

const SUB := "[bgcolor=#ff000026][color=white]%s[/color][/bgcolor]"
const ADD := "[bgcolor=#00ff0026][color=white]%s[/color][/bgcolor]"


func _colored_diff(current: String, expected: String) -> String:
	return GdAssertMessages.colored_diff(current, expected, GdDiffTool.diff(current, expected))


#region colored_diff
func test_colored_diff_empty() -> void:
	assert_str(_colored_diff("", "")).is_equal("<empty>")


func test_colored_diff_equal() -> void:
	assert_str(_colored_diff("abc", "abc")).is_equal("abc")


func test_colored_diff_replace() -> void:
	# the missing expected characters are shown first, followed by the additional current characters
	assert_str(_colored_diff("Abc", "abc")).is_equal(SUB % "a" + ADD % "A" + "bc")
	assert_str(_colored_diff("abc", "abd")).is_equal("ab" + SUB % "d" + ADD % "c")


func test_colored_diff_additional_characters() -> void:
	assert_str(_colored_diff("abXcd", "abcd")).is_equal("ab" + ADD % "X" + "cd")
	assert_str(_colored_diff("abc", "")).is_equal(ADD % "abc")


func test_colored_diff_missing_characters() -> void:
	assert_str(_colored_diff("abcd", "abXcd")).is_equal("ab" + SUB % "X" + "cd")
	assert_str(_colored_diff("", "abc")).is_equal(SUB % "abc")


func test_colored_diff_multiple_hunks() -> void:
	assert_str(_colored_diff("hello world", "hallo welt")) \
		.is_equal("h" + SUB % "a" + ADD % "e" + "llo w" + SUB % "e" + ADD % "or" + "l" + SUB % "t" + ADD % "d")


func test_colored_diff_formats_control_characters() -> void:
	assert_str(_colored_diff("line1\nline2", "line1\nline3")).is_equal("line1\nline" + SUB % "3" + ADD % "2")
	assert_str(_colored_diff("a\tb", "a b")).is_equal("a" + SUB % " " + ADD % "<TAB>" + "b")
	assert_str(_colored_diff("ab\u001bcd", "abcd")).is_equal("ab" + ADD % "<ESC>" + "cd")
#endregion


#region format_chars
func test_format_chars() -> void:
	assert_str(GdAssertMessages.format_chars("", GdAssertMessages.ADD_COLOR)).is_empty()
	assert_str(GdAssertMessages.format_chars("abc", GdAssertMessages.ADD_COLOR)).is_equal(ADD % "abc")
	assert_str(GdAssertMessages.format_chars("a\r\n\u0001b\u007f", GdAssertMessages.SUB_COLOR)).is_equal(SUB % "a<CR><LF><0x01>b<DEL>")
#endregion


#region _colored_value
func test_colored_value_string() -> void:
	assert_str(GdAssertMessages._colored_value("")).contains("<empty>")
	# the former diff marker characters (Ö, ×) are plain characters
	assert_str(GdAssertMessages._colored_value("aÖb×c")).contains("aÖb×c")
#endregion
