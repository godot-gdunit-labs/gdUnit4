# GdUnit generated TestSuite
class_name GdFunctionArgumentTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/gdUnit4/src/core/parse/GdFunctionArgument.gd'


func test__parse_argument_as_array_typ1() -> void:
	var test_parameters := """[
		[1, "flowchart TD\nid>This is a  flag shaped node]"],
		[
			2,
			"flowchart TD\nid(((This is a\tdouble circle node)))"
		],
		[3,
			"flowchart TD\nid((This is a circular node))"],
		[
			4, "flowchart TD\nid>This is a flag shaped node]"
		],
		[5, "flowchart TD\nid{'This is a rhombus node'}"],
		[6, 'flowchart TD\nid((This is a circular node))'],
		[7, 'flowchart TD\nid>This is a flag shaped node]'], [8, 'flowchart TD\nid{"This is a rhombus node"}'],
		[9, \"\"\"
			flowchart TD
			id{"This is a  rhombus node"}
			\"\"\"]
		]"""

	var fa := GdFunctionArgument.new("test_parameters", TYPE_STRING, test_parameters)
	assert_array(fa.parameter_sets()).contains_exactly([
		"""[1, "flowchart TD\nid>This is a  flag shaped node]"]""",
		"""[2, "flowchart TD\nid(((This is a\tdouble circle node)))"]""",
		"""[3, "flowchart TD\nid((This is a circular node))"]""",
		"""[4, "flowchart TD\nid>This is a flag shaped node]"]""",
		"""[5, "flowchart TD\nid{'This is a rhombus node'}"]""",
		"""[6, 'flowchart TD\nid((This is a circular node))']""",
		"""[7, 'flowchart TD\nid>This is a flag shaped node]']""",
		"""[8, 'flowchart TD\nid{"This is a rhombus node"}']""",
		"""[9, \"\"\"\nflowchart TD\nid{"This is a  rhombus node"}\n\"\"\"]"""
		]
	)


func test__parse_argument_as_array_typ2() -> void:
	var test_parameters := """[
		["test_a", null, "LOG", {}],
		[
			"test_b",
			Node2D,
			null,
			{Node2D: "ER,ROR"}
		],
		[
			"test_c",
			Node2D,
			"LOG",
			{Node2D: "LOG"}
		]
	]"""
	var fa := GdFunctionArgument.new("test_parameters", TYPE_STRING, test_parameters)
	assert_array(fa.parameter_sets()).contains_exactly([
		"""["test_a", null, "LOG", {}]""",
		"""["test_b", Node2D, null, {Node2D: "ER,ROR"}]""",
		"""["test_c", Node2D, "LOG", {Node2D: "LOG"}]"""
		]
	)


func test__parse_argument_as_array_bad_formatted() -> void:
	var test_parameters := """[
		["test_a", null, "LOG", {}],
		[
				"test_b",
			Node2D,
			null,
			{Node2D: "ER,ROR"}
		],
			[
			"test_c",
			Node2D,
			"LOG",
			{Node2D: "LOG 1"}
		]

		  ]"""
	var fa := GdFunctionArgument.new("test_parameters", TYPE_STRING, test_parameters)
	assert_array(fa.parameter_sets()).contains_exactly([
		"""["test_a", null, "LOG", {}]""",
		"""["test_b", Node2D, null, {Node2D: "ER,ROR"}]""",
		"""["test_c", Node2D, "LOG", {Node2D: "LOG 1"}]"""
		]
	)


func test_parse_argument_as_array_ends_with_additional_comma() -> void:
	var test_parameters := """
			[
			[true, 'bool'],
			[42, 'int'],
			['foo', 'String'],
		]"""
	var fa := GdFunctionArgument.new("test_parameters", TYPE_STRING, test_parameters)
	assert_array(fa.parameter_sets()).contains_exactly([
		"""[true, 'bool']""",
		"""[42, 'int']""",
		"""['foo', 'String']"""
		]
	)


func test__parse_argument_as_reference() -> void:
	var test_parameters := "_test_args()"

	var fa := GdFunctionArgument.new("test_parameters", TYPE_STRING, test_parameters)
	assert_array(fa.parameter_sets()).is_empty()


func test_parse_parameter_set_with_const_data_in_array() -> void:
	var test_parameters := "[_data1, _data2]"

	var fa := GdFunctionArgument.new("test_parameters", TYPE_STRING, test_parameters)
	assert_array(fa.parameter_sets()).contains_exactly(["_data1", "_data2"])


func test__parse_argument_with_strings_contaning_newlines() -> void:
	assert_array(GdFunctionArgument._parse_parameter_set("[]"))\
		.is_empty()
	assert_array(GdFunctionArgument._parse_parameter_set("[_data1, _data2]"))\
		.contains_exactly("_data1", "_data2")

	var test_parameters := """[
		[8, 'flowchart TD\nid{"This is a rhombus node"}'],
		[9, "
			flowchart TD
			id{"This is a rhombus node"}
			"],
		]"""
	var fa := GdFunctionArgument.new("test_parameters", TYPE_STRING, test_parameters)
	assert_array(fa.parameter_sets())\
		.contains_exactly(
			"""[8, 'flowchart TD\nid{"This is a rhombus node"}']""",
			"""[9, "\nflowchart TD\nid{"This is a rhombus node"}\n"]""")


#region _parse_parameter_set_implementations
static func _big_input() -> String:
	return """[
		[1, "simple double-quoted string"],
		[2, 'simple single-quoted string'],
		[3, "escape newline\nafter"],
		[4, 'single escape\nnewline'],
		[5, \"\"\"triple\nquoted\"\"\"],
		[6, "braces {and \"inner\" quotes} here"],
		[7, "comma, inside, double, string"],
		[8, 'comma, inside, single, string'],
		[9, "brackets [inside] string"],
		[10, true, false, null],
		[11, 42, 3.14, -7],
		[12, "mixed types", 42, null, true],
		[13, {key: "value", other: 123}],
		[14, ["nested", "array", 99]],
		[15, "
			real multiline
			block string
			"],
		[16, Node2D, Vector2(1, 2)],
		[17, "tab\there and\there"],
		[
			18,
			"badly formatted element",
			true,
			42
		],
		[19, \"\"\"second\ntriple\nquoted\"\"\", false],
		[20, {Node2D: "ER,ROR"}, ["a", "b"]],
		]"""


func test__parse_parameter_set_v2_correctness() -> void:
	var input := _big_input()
	var expected := GdFunctionArgument._parse_parameter_set(input)
	var actual := GdFunctionArgument._parse_parameter_set_v2(input)
	assert_array(actual).has_size(expected.size())
	for i in expected.size():
		assert_str(actual[i]).is_equal(expected[i])


func test__parse_parameter_set_v2_performance() -> void:
	var input := _big_input()
	const ITERATIONS := 10000

	# Verify correctness before timing
	var expected := GdFunctionArgument._parse_parameter_set(input)
	var actual := GdFunctionArgument._parse_parameter_set_v2(input)
	assert_array(actual).has_size(expected.size())

	# Warmup — ensures both functions are at the same interpretation state
	for _w in 50:
		GdFunctionArgument._parse_parameter_set(input)
		GdFunctionArgument._parse_parameter_set_v2(input)

	var t0 := Time.get_ticks_usec()
	for _i in ITERATIONS:
		GdFunctionArgument._parse_parameter_set(input)
	var elapsed_v1 := Time.get_ticks_usec() - t0

	var t1 := Time.get_ticks_usec()
	for _j in ITERATIONS:
		GdFunctionArgument._parse_parameter_set_v2(input)
	var elapsed_v2 := Time.get_ticks_usec() - t1

	print("v1: %d µs  v2: %d µs  speedup: %.2fx" % [elapsed_v1, elapsed_v2, elapsed_v1 / float(elapsed_v2)])
	assert_int(elapsed_v2).is_less(elapsed_v1)


func test__parse_parameter_set_all_implementations_correctness() -> void:
	var input := _big_input()
	var reference := GdFunctionArgument._parse_parameter_set_v2(input)
	var labels := ["v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11"]
	var impls: Array = [
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v3(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v4(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v5(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v6(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v7(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v8(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v9(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v10(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v11(s),
	]
	for idx in impls.size():
		var actual: PackedStringArray = impls[idx].call(input)
		assert_array(actual).has_size(reference.size())
		for i in reference.size():
			assert_str(actual[i]).is_equal(reference[i])


func test__parse_parameter_set_all_implementations_performance() -> void:
	var input := _big_input()
	const ITERATIONS := 10000
	var labels := ["v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11"]
	var impls: Array = [
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v2(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v3(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v4(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v5(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v6(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v7(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v8(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v9(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v10(s),
		func(s: String) -> PackedStringArray: return GdFunctionArgument._parse_parameter_set_v11(s),
	]
	for fn: Callable in impls:
		for _w in 50:
			fn.call(input)
	var times: Array[int] = []
	for fn: Callable in impls:
		var t0 := Time.get_ticks_usec()
		for _i in ITERATIONS:
			fn.call(input)
		times.append(Time.get_ticks_usec() - t0)
	var min_time: int = times.min()
	var rows: Array = []
	for i in labels.size():
		rows.append([labels[i], times[i], times[i] / float(min_time)])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return a[1] < b[1])
	print("\nPerformance (%d iters, µs total):" % ITERATIONS)
	print("  %-5s  %9s  %s" % ["impl", "µs", "factor"])
	for r: Array in rows:
		print("  %-5s  %9d  %.2fx" % [r[0], r[1], r[2]])
	assert_int(min_time).is_greater(0)
#endregion
