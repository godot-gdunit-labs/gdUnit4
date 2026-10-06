# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name GdDiffToolTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit4/src/core/GdDiffTool.gd'


# Converts the hunks into [current_start, current_len, expected_start, expected_len] to keep the assertions compact
func _as_arrays(hunks: Array[GdDiffTool.Hunk]) -> Array[Array]:
	var result: Array[Array] = []
	for hunk in hunks:
		result.append([hunk.current_start, hunk.current_len, hunk.expected_start, hunk.expected_len])
	return result


# Applies the hunks to `current` and verifies that the common text between the hunks is equal on both sides.
# Returns the rebuilt value, it must be equal to `expected`.
func _apply(current: String, expected: String, hunks: Array[GdDiffTool.Hunk]) -> String:
	var parts := PackedStringArray()
	var cur_pos := 0
	var exp_pos := 0
	for hunk in hunks:
		var cur_common := current.substr(cur_pos, hunk.current_start - cur_pos)
		var exp_common := expected.substr(exp_pos, hunk.expected_start - exp_pos)
		if cur_common != exp_common:
			return "hunks are not aligned: common text '%s' != '%s' before %s" % [cur_common.left(20), exp_common.left(20), hunk]
		parts.append(cur_common)
		parts.append(expected.substr(hunk.expected_start, hunk.expected_len))
		cur_pos = hunk.current_start + hunk.current_len
		exp_pos = hunk.expected_start + hunk.expected_len
	var cur_rest := current.substr(cur_pos)
	if cur_rest != expected.substr(exp_pos):
		return "hunks are not aligned: common rest text differs"
	parts.append(cur_rest)
	return "".join(parts)


#region diff
func test_diff_empty() -> void:
	assert_array(GdDiffTool.diff("", "")).is_empty()


func test_diff_equals() -> void:
	assert_array(GdDiffTool.diff("Abc", "Abc")).is_empty()


func test_diff_replace() -> void:
	# tests the result of the diff like assert_str("Abc").is_equal("abc")
	assert_array(_as_arrays(GdDiffTool.diff("Abc", "abc"))).is_equal([[0, 1, 0, 1]])
	assert_array(_as_arrays(GdDiffTool.diff("abc", "abd"))).is_equal([[2, 1, 2, 1]])


func test_diff_insert() -> void:
	assert_array(_as_arrays(GdDiffTool.diff("abcd", "abXcd"))).is_equal([[2, 0, 2, 1]])
	assert_array(_as_arrays(GdDiffTool.diff("bcd", "abcd"))).is_equal([[0, 0, 0, 1]])
	assert_array(_as_arrays(GdDiffTool.diff("abc", "abcd"))).is_equal([[3, 0, 3, 1]])
	assert_array(_as_arrays(GdDiffTool.diff("", "abc"))).is_equal([[0, 0, 0, 3]])


func test_diff_remove() -> void:
	assert_array(_as_arrays(GdDiffTool.diff("abXcd", "abcd"))).is_equal([[2, 1, 2, 0]])
	assert_array(_as_arrays(GdDiffTool.diff("abcd", "bcd"))).is_equal([[0, 1, 0, 0]])
	assert_array(_as_arrays(GdDiffTool.diff("abcd", "abc"))).is_equal([[3, 1, 3, 0]])
	assert_array(_as_arrays(GdDiffTool.diff("abc", ""))).is_equal([[0, 3, 0, 0]])


func test_diff_repeated_characters() -> void:
	assert_array(_as_arrays(GdDiffTool.diff("aa", "a"))).is_equal([[1, 1, 1, 0]])
	assert_array(_as_arrays(GdDiffTool.diff("a", "aa"))).is_equal([[1, 0, 1, 1]])


func test_diff_multiple_hunks() -> void:
	assert_array(_as_arrays(GdDiffTool.diff("hello world", "hallo welt"))) \
		.is_equal([[1, 1, 1, 1], [7, 2, 7, 1], [10, 1, 9, 1]])


func test_diff_completely_different() -> void:
	assert_array(_as_arrays(GdDiffTool.diff("abcdef", "xyz"))).is_equal([[0, 6, 0, 3]])


func test_diff_unicode() -> void:
	# positions are character positions, not byte positions
	assert_array(_as_arrays(GdDiffTool.diff("ä€ü", "ä€x"))).is_equal([[2, 1, 2, 1]])


@warning_ignore("unused_parameter")
func test_diff_rebuilds_expected(fuzzer := Fuzzers.rand_str(1, 200), fuzzer_iterations := 200) -> void:
	# the hunks applied to the current value must always result in the expected value
	var current: String = fuzzer.next_value()
	var expected: String = fuzzer.next_value()

	assert_str(_apply(current, expected, GdDiffTool.diff(current, expected))).is_equal(expected)


func test_diff_rebuilds_expected_on_similar_values() -> void:
	# random edits on a text, the diff must be precise and valid
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for iteration in 50:
		var current := ""
		for i in 300:
			current += char(97 + rng.randi_range(0, 5))
		var expected := current
		for edit in rng.randi_range(1, 10):
			var pos := rng.randi_range(0, expected.length())
			match rng.randi_range(0, 2):
				0:
					expected = expected.insert(pos, char(97 + rng.randi_range(0, 5)))
				1:
					expected = expected.erase(pos, rng.randi_range(1, 3))
				2:
					expected = expected.erase(pos, 1).insert(pos, "#")

		assert_str(_apply(current, expected, GdDiffTool.diff(current, expected))).is_equal(expected)
#endregion


#region large values GD-1327
func test_diff_large_similar_values() -> void:
	# the common prefix and suffix is cut off, a single change in a huge value is cheap
	var value := "abcdefghij".repeat(13200)
	var expected := value.substr(0, 60000) + "XYZ" + value.substr(60000)

	assert_array(_as_arrays(GdDiffTool.diff(value, expected))).is_equal([[60000, 0, 60000, 3]])
	assert_array(_as_arrays(GdDiffTool.diff(expected, value))).is_equal([[60000, 3, 60000, 0]])


func test_diff_large_value_with_appended_character() -> void:
	var value := "a".repeat(131072)

	assert_array(_as_arrays(GdDiffTool.diff(value, value + "x"))).is_equal([[131072, 0, 131072, 1]])


func test_diff_large_different_values() -> void:
	# GD-1327: large values without any match used to run out of memory (quadratic growth of the edit trace),
	# now the work is bounded and the unmatched regions are reported as changed
	var value := "a".repeat(131072)
	var expected := "b".repeat(131072)

	assert_array(_as_arrays(GdDiffTool.diff(value, expected))).is_equal([[0, 131072, 0, 131072]])


func test_diff_large_random_values() -> void:
	# a worst case for the search: the values share the alphabet but have no relation
	var rng := RandomNumberGenerator.new()
	rng.seed = 1327
	var current := ""
	var expected := ""
	for i in 20000:
		current += char(97 + rng.randi_range(0, 3))
		expected += char(97 + rng.randi_range(0, 3))

	var hunks := GdDiffTool.diff(current, expected)

	assert_array(hunks).is_not_empty()
	assert_str(_apply(current, expected, hunks)).is_equal(expected)


func _replace_every(value: String, step: int) -> String:
	var result := value
	for pos in range(step / 2, value.length(), step):
		result = result.erase(pos, 1).insert(pos, "#")
	return result


func _random_text(length: int, seed_value: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var text := PackedStringArray()
	for i in length:
		text.append(char(97 + rng.randi_range(0, 25)))
	return "".join(text)


func test_diff_large_value_with_few_changes() -> void:
	# the edit cost stays below the limit (MIN_COST_LIMIT), the diff is minimal
	var current := _random_text(50000, 7)
	var expected := _replace_every(current, 500)

	var hunks := GdDiffTool.diff(current, expected)

	# 100 replaced characters are 100 removed and 100 inserted characters, equal cost scripts may split a hunk
	var edit_size := 0
	for hunk in hunks:
		edit_size += hunk.current_len + hunk.expected_len
	assert_int(edit_size).is_equal(200)
	assert_str(_apply(current, expected, hunks)).is_equal(expected)


func test_diff_large_value_with_many_changes() -> void:
	# the edit cost exceeds the limit, the diff is no longer minimal but still valid
	var current := _random_text(50000, 7)
	var expected := _replace_every(current, 100)

	var hunks := GdDiffTool.diff(current, expected)

	assert_array(hunks).is_not_empty()
	assert_str(_apply(current, expected, hunks)).is_equal(expected)
#endregion
