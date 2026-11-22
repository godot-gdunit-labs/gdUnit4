class_name GdUnitBenchmarkResultTest
extends GdUnitTestSuite

const NA := GdUnitBenchmarkStatistics.NA
const SAMPLES: Array[float] = [388.1, 387.9, 389.4, 388.0, 389.2, 388.5, 387.7, 388.3, 552.0, 388.9]


static func json_round_trip(serialized: Dictionary) -> Dictionary:
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(serialized, "", false, true))
	return parsed


func _measured_result() -> GdUnitBenchmarkResult:
	var result := GdUnitBenchmarkResult.new()
	result.suite = "res://test/benchmarks/ArrayBenchmark.gd"
	result.benchmark = "bench_sort"
	result.display_name = "bench_sort [size=10, factor=2.0, name=small]"
	result.parameters = { "size": 10, "factor": 2.0, "name": "small" }
	result.is_async = true
	result.n = 120_000
	result.rounds = 10
	result.warmup = 3
	result.overhead_ns = 86.0
	result.set_samples(PackedFloat64Array(SAMPLES))
	result.ratio = 3.23
	result.ratio_sd = 0.1
	result.hints = PackedStringArray(["1 outlier was removed (0.552 µs)"])
	return result


#region serialize
func test_serialize_measured() -> void:
	var serialized := _measured_result().serialize()

	assert_str(serialized["state"]).is_equal("measured")
	assert_dict(serialized["parameters"]).is_equal({ "size": 10, "factor": 2.0, "name": "small" })
	assert_dict(serialized["parameter_types"]).is_equal({ "size": TYPE_INT, "factor": TYPE_FLOAT, "name": TYPE_STRING })
	assert_bool(serialized["async"]).is_true()
	assert_array(serialized["samples_ns"]).contains_exactly(SAMPLES)
	assert_array(serialized["outliers_ns"]).contains_exactly([552.0])
	assert_float(serialized["mean_ns"]).is_equal_approx(388.444444, 0.000001)
	assert_float(serialized["median_ns"]).is_equal(388.3)
	assert_float(serialized["min_ns"]).is_equal(387.7)
	assert_float(serialized["max_ns"]).is_equal(389.4)
	assert_float(serialized["ratio"]).is_equal(3.23)
	assert_array(serialized["hints"]).contains_exactly(["1 outlier was removed (0.552 µs)"])


func test_serialize_na_as_null() -> void:
	var result := GdUnitBenchmarkResult.new()
	result.state = GdUnitBenchmarkResult.State.FAILED
	result.error = "push_error in bench_sort:12"

	var serialized := result.serialize()

	assert_str(serialized["state"]).is_equal("failed")
	assert_str(serialized["error"]).is_equal("push_error in bench_sort:12")
	for key: String in ["overhead_ns", "mean_ns", "error_ns", "stddev_ns", "median_ns", "min_ns", "max_ns", "ratio", "ratio_sd"]:
		assert_that(serialized[key]).override_failure_message(key).is_null()
	assert_array(serialized["samples_ns"]).is_empty()
	assert_array(serialized["outliers_ns"]).is_empty()


func test_serialize_non_json_parameter_as_text() -> void:
	var result := GdUnitBenchmarkResult.new()
	result.parameters = { "offset": Vector2(1, 2) }

	var serialized := result.serialize()

	assert_dict(serialized["parameters"]).is_equal({ "offset": "(1.0, 2.0)" })
	assert_dict(serialized["parameter_types"]).is_equal({ "offset": TYPE_STRING })
#endregion


#region round trip
func test_round_trip_measured() -> void:
	var result := _measured_result()

	var restored := GdUnitBenchmarkResult.deserialize(json_round_trip(result.serialize()))

	assert_dict(restored.serialize()).is_equal(result.serialize())
	assert_str(restored.suite).is_equal("res://test/benchmarks/ArrayBenchmark.gd")
	assert_str(restored.benchmark).is_equal("bench_sort")
	assert_str(restored.display_name).is_equal("bench_sort [size=10, factor=2.0, name=small]")
	assert_int(restored.state).is_equal(GdUnitBenchmarkResult.State.MEASURED)
	assert_bool(restored.is_async).is_true()
	assert_bool(restored.baseline).is_false()
	assert_float(restored.overhead_ns).is_equal(86.0)
	assert_float(restored.ratio).is_equal(3.23)
	assert_float(restored.ratio_sd).is_equal(0.1)
	assert_array(restored.samples()).contains_exactly(SAMPLES)
	assert_array(restored.statistics().outliers).contains_exactly([552.0])
	assert_float(restored.statistics().mean).is_equal(result.statistics().mean)
	assert_float(restored.statistics().error).is_equal(result.statistics().error)
	assert_array(restored.hints).contains_exactly(["1 outlier was removed (0.552 µs)"])


func test_round_trip_keeps_int_types() -> void:
	var restored := GdUnitBenchmarkResult.deserialize(json_round_trip(_measured_result().serialize()))

	assert_int(typeof(restored.n)).is_equal(TYPE_INT)
	assert_int(restored.n).is_equal(120_000)
	assert_int(restored.rounds).is_equal(10)
	assert_int(restored.warmup).is_equal(3)


func test_round_trip_keeps_parameter_types() -> void:
	var restored := GdUnitBenchmarkResult.deserialize(json_round_trip(_measured_result().serialize()))

	assert_dict(restored.parameters).is_equal({ "size": 10, "factor": 2.0, "name": "small" })
	assert_int(typeof(restored.parameters["size"])).is_equal(TYPE_INT)
	assert_int(typeof(restored.parameters["factor"])).is_equal(TYPE_FLOAT)
	assert_int(typeof(restored.parameters["name"])).is_equal(TYPE_STRING)
	assert_array(restored.parameters.keys()).contains_exactly(["size", "factor", "name"])


func test_round_trip_na() -> void:
	var result := GdUnitBenchmarkResult.new()
	result.state = GdUnitBenchmarkResult.State.SKIPPED
	result.set_samples(PackedFloat64Array([42.0]))

	var restored := GdUnitBenchmarkResult.deserialize(json_round_trip(result.serialize()))

	assert_int(restored.state).is_equal(GdUnitBenchmarkResult.State.SKIPPED)
	assert_bool(GdUnitBenchmarkStatistics.is_na(restored.overhead_ns)).is_true()
	assert_bool(GdUnitBenchmarkStatistics.is_na(restored.ratio)).is_true()
	assert_bool(GdUnitBenchmarkStatistics.is_na(restored.ratio_sd)).is_true()
	assert_bool(GdUnitBenchmarkStatistics.is_na(restored.statistics().stddev)).is_true()
	assert_bool(GdUnitBenchmarkStatistics.is_na(restored.statistics().error)).is_true()
	assert_float(restored.statistics().mean).is_equal(42.0)
	assert_dict(restored.serialize()).is_equal(result.serialize())


func test_round_trip_baseline_failed() -> void:
	var result := GdUnitBenchmarkResult.new()
	result.baseline = true
	result.state = GdUnitBenchmarkResult.State.FAILED
	result.error = "Script error in setup:7"

	var restored := GdUnitBenchmarkResult.deserialize(json_round_trip(result.serialize()))

	assert_bool(restored.baseline).is_true()
	assert_int(restored.state).is_equal(GdUnitBenchmarkResult.State.FAILED)
	assert_str(restored.error).is_equal("Script error in setup:7")
	assert_array(restored.samples()).is_empty()
	assert_dict(restored.serialize()).is_equal(result.serialize())
#endregion


#region samples
func test_set_samples_copies_values() -> void:
	var samples := PackedFloat64Array([1.0, 2.0])
	var result := GdUnitBenchmarkResult.new()

	result.set_samples(samples)
	samples.append(3.0)

	assert_array(result.samples()).contains_exactly([1.0, 2.0])
	assert_float(result.statistics().mean).is_equal(1.5)
#endregion
