class_name GdUnitBenchmarkEventTest
extends GdUnitTestSuite

const RESOURCE_PATH := "res://test/benchmarks/ArrayBenchmark.gd"


func _round_trip(event: GdUnitBenchmarkEvent) -> GdUnitBenchmarkEvent:
	return GdUnitBenchmarkEvent.deserialize(GdUnitBenchmarkResultTest.json_round_trip(event.serialize()))


func _result() -> GdUnitBenchmarkResult:
	var result := GdUnitBenchmarkResult.new()
	result.resource_path = RESOURCE_PATH
	result.benchmark = "bench_find"
	result.display_name = "bench_find [size=10]"
	result.parameters = { "size": 10 }
	result.baseline = true
	result.n = 400_000
	result.rounds = 10
	result.warmup = 3
	result.overhead_ns = 86.0
	result.set_samples(PackedFloat64Array([120.1, 119.8, 120.4, 120.0]))
	result.ratio = 1.0
	result.ratio_sd = 0.0
	return result


#region round trip
func test_session_start() -> void:
	var event := GdUnitBenchmarkEvent.session_start(GdUnitBenchmarkEnvironment.current(true))

	var restored := _round_trip(event)

	assert_int(restored.type).is_equal(GdUnitBenchmarkEvent.Type.SESSION_START)
	assert_that(restored.environment).is_equal(event.environment)
	assert_object(restored.result).is_null()
	assert_dict(restored.serialize()).is_equal(event.serialize())


func test_suite_before() -> void:
	var restored := _round_trip(GdUnitBenchmarkEvent.suite_before(RESOURCE_PATH))

	assert_int(restored.type).is_equal(GdUnitBenchmarkEvent.Type.SUITE_BEFORE)
	assert_str(restored.resource_path).is_equal(RESOURCE_PATH)
	assert_object(restored.environment).is_null()
	assert_object(restored.result).is_null()


func test_benchmark_before() -> void:
	var guid := GdUnitGUID.new()

	var restored := _round_trip(GdUnitBenchmarkEvent.benchmark_before(RESOURCE_PATH, guid))

	assert_int(restored.type).is_equal(GdUnitBenchmarkEvent.Type.BENCHMARK_BEFORE)
	assert_str(restored.resource_path).is_equal(RESOURCE_PATH)
	assert_bool(GdUnitGUID.new(restored.guid).equals(guid)).is_true()
	assert_object(restored.result).is_null()


func test_benchmark_after() -> void:
	var guid := GdUnitGUID.new()
	var event := GdUnitBenchmarkEvent.benchmark_after(RESOURCE_PATH, guid, _result())

	var restored := _round_trip(event)

	assert_int(restored.type).is_equal(GdUnitBenchmarkEvent.Type.BENCHMARK_AFTER)
	assert_str(restored.resource_path).is_equal(RESOURCE_PATH)
	assert_bool(GdUnitGUID.new(restored.guid).equals(guid)).is_true()
	assert_dict(restored.result.serialize()).is_equal(event.result.serialize())
	assert_dict(restored.result.parameters).is_equal({ "size": 10 })
	assert_object(restored.environment).is_null()


func test_suite_after() -> void:
	var restored := _round_trip(GdUnitBenchmarkEvent.suite_after(RESOURCE_PATH))

	assert_int(restored.type).is_equal(GdUnitBenchmarkEvent.Type.SUITE_AFTER)
	assert_str(restored.resource_path).is_equal(RESOURCE_PATH)


func test_session_close() -> void:
	var restored := _round_trip(GdUnitBenchmarkEvent.session_close())

	assert_int(restored.type).is_equal(GdUnitBenchmarkEvent.Type.SESSION_CLOSE)
	assert_str(restored.resource_path).is_empty()
	assert_str(restored.guid).is_empty()
	assert_object(restored.environment).is_null()
	assert_object(restored.result).is_null()
#endregion


#region serialize
func test_serialize_keys() -> void:
	assert_dict(GdUnitBenchmarkEvent.suite_before(RESOURCE_PATH).serialize()) \
		.is_equal({ "type": GdUnitBenchmarkEvent.Type.SUITE_BEFORE, "resource_path": RESOURCE_PATH, "guid": "" })


func test_serialize_includes_result() -> void:
	var serialized := GdUnitBenchmarkEvent.benchmark_after(RESOURCE_PATH, GdUnitGUID.new(), _result()).serialize()

	assert_dict(serialized).contains_keys("type", "resource_path", "guid", "result").not_contains_keys("environment")


func test_serialize_includes_environment() -> void:
	var serialized := GdUnitBenchmarkEvent.session_start(GdUnitBenchmarkEnvironment.current(false)).serialize()

	assert_dict(serialized).contains_keys("environment").not_contains_keys("result")
#endregion


#region deserialize
func test_deserialize_empty() -> void:
	assert_that(GdUnitBenchmarkEvent.deserialize({})).is_equal(GdUnitBenchmarkEvent.new())


func test_deserialize_type_out_of_range() -> void:
	assert_int(GdUnitBenchmarkEvent.deserialize({ "type": 99 }).type).is_equal(GdUnitBenchmarkEvent.Type.SESSION_CLOSE)
	assert_int(GdUnitBenchmarkEvent.deserialize({ "type": -1 }).type).is_equal(GdUnitBenchmarkEvent.Type.SESSION_START)
#endregion
