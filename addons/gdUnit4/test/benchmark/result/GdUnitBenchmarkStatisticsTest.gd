class_name GdUnitBenchmarkStatisticsTest
extends GdUnitTestSuite

const NA := GdUnitBenchmarkStatistics.NA
const TOLERANCE := 0.000001
const SAMPLES_RESULT_MODEL: Array[float] = [388.1, 387.9, 389.4, 388.0, 391.2, 388.5, 387.7, 388.3, 552.0, 388.9]
const SAMPLES_LOWER_AND_UPPER_OUTLIERS: Array[float] = [12.5, 100.2, 101.7, 99.8, 100.9, 102.3, 98.6, 101.1, 180.4, 100.5, 175.0]


#region outliers
func test_upper_outliers_removed_and_kept() -> void:
	var samples := PackedFloat64Array(SAMPLES_RESULT_MODEL)
	var statistics := GdUnitBenchmarkStatistics.new(samples)

	assert_array(statistics.outliers).contains_exactly([391.2, 552.0])
	_assert_statistics(statistics, 388.35, 1.081599999999988, 0.5656854249492317, 388.2, 387.7, 389.4)
	assert_array(samples).contains_exactly(SAMPLES_RESULT_MODEL)


func test_lower_outliers_kept() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array(SAMPLES_LOWER_AND_UPPER_OUTLIERS))

	assert_array(statistics.outliers).contains_exactly([180.4, 175.0])
	_assert_statistics(statistics, 90.84444444444445, 49.399807501076, 29.398814224008724, 100.5, 12.5, 102.3)


func test_value_on_upper_fence_kept() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array([1.0, 2.0, 3.0, 4.0, 7.0]))

	assert_array(statistics.outliers).is_empty()
	_assert_statistics(statistics, 3.4, 8.864537551389805, 2.3021728866442674, 3.0, 1.0, 7.0)


func test_value_above_upper_fence_removed() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array([1.0, 2.0, 3.0, 4.0, 7.5]))

	assert_array(statistics.outliers).contains_exactly([7.5])
	_assert_statistics(statistics, 2.5, 8.342406127730776, 1.2909944487358056, 2.5, 1.0, 4.0)


func test_only_outliers_deviate() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array([5.0, 9.0, 5.0, 5.0, 5.0]))

	assert_array(statistics.outliers).contains_exactly([9.0])
	_assert_statistics(statistics, 5.0, 0.0, 0.0, 5.0, 5.0, 5.0)
#endregion


#region value count
func test_no_values() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array())

	assert_array(statistics.outliers).is_empty()
	_assert_statistics(statistics, NA, NA, NA, NA, NA, NA)
	_assert_statistics(GdUnitBenchmarkStatistics.new(), NA, NA, NA, NA, NA, NA)


func test_one_value() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array([42.0]))

	assert_array(statistics.outliers).is_empty()
	_assert_statistics(statistics, 42.0, NA, NA, 42.0, 42.0, 42.0)


func test_two_values() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array([5.0, 3.0]))

	assert_array(statistics.outliers).is_empty()
	_assert_statistics(statistics, 4.0, 636.619, 1.4142135623730951, 4.0, 3.0, 5.0)


func test_equal_values() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array([7.5, 7.5, 7.5, 7.5, 7.5]))

	assert_array(statistics.outliers).is_empty()
	_assert_statistics(statistics, 7.5, 0.0, 0.0, 7.5, 7.5, 7.5)
#endregion


#region t quantile
func test_t_quantile() -> void:
	assert_float(GdUnitBenchmarkStatistics.t_quantile(1)).is_equal(636.619)
	assert_float(GdUnitBenchmarkStatistics.t_quantile(8)).is_equal(5.041)
	assert_float(GdUnitBenchmarkStatistics.t_quantile(30)).is_equal(3.646)
	assert_float(GdUnitBenchmarkStatistics.t_quantile(31)).is_equal(3.291)
	assert_float(GdUnitBenchmarkStatistics.t_quantile(1000)).is_equal(3.291)
	assert_bool(GdUnitBenchmarkStatistics.is_na(GdUnitBenchmarkStatistics.t_quantile(0))).is_true()


func test_error_at_table_end() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(_generated_samples(31))

	assert_array(statistics.outliers).is_empty()
	_assert_statistics(statistics, 1010.4193548387096, 4.430953288407737, 6.766457436248243, 1010.0, 1000.0, 1022.0)


func test_error_above_table() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(_generated_samples(32))

	assert_array(statistics.outliers).is_empty()
	_assert_statistics(statistics, 1010.71875, 3.9959067392860055, 6.868508665665537, 1010.5, 1000.0, 1022.0)
#endregion


#region ratio
func test_ratio() -> void:
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array(SAMPLES_LOWER_AND_UPPER_OUTLIERS))
	var baseline := GdUnitBenchmarkStatistics.new(PackedFloat64Array(SAMPLES_RESULT_MODEL))

	assert_float(statistics.ratio(baseline)).is_equal_approx(0.2339241520392544, TOLERANCE)
	assert_float(statistics.ratio_sd(baseline)).is_equal_approx(0.07570261885721567, TOLERANCE)


func test_ratio_of_baseline() -> void:
	var baseline := GdUnitBenchmarkStatistics.new(PackedFloat64Array(SAMPLES_RESULT_MODEL))

	assert_float(baseline.ratio(baseline)).is_equal(1.0)
	assert_float(baseline.ratio_sd(baseline)).is_equal(0.0)


func test_ratio_with_one_value() -> void:
	var one_value := GdUnitBenchmarkStatistics.new(PackedFloat64Array([42.0]))
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array(SAMPLES_RESULT_MODEL))

	assert_float(one_value.ratio(statistics)).is_equal_approx(0.10814986481266897, TOLERANCE)
	_assert_value(one_value.ratio_sd(statistics), NA)
	assert_float(statistics.ratio(one_value)).is_equal_approx(9.246428571428572, TOLERANCE)
	_assert_value(statistics.ratio_sd(one_value), NA)
	assert_float(one_value.ratio(one_value)).is_equal(1.0)
	_assert_value(one_value.ratio_sd(one_value), NA)


func test_ratio_without_values() -> void:
	var no_values := GdUnitBenchmarkStatistics.new()
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array(SAMPLES_RESULT_MODEL))

	_assert_value(no_values.ratio(statistics), NA)
	_assert_value(no_values.ratio_sd(statistics), NA)
	_assert_value(statistics.ratio(no_values), NA)
	_assert_value(statistics.ratio_sd(no_values), NA)
	_assert_value(no_values.ratio(no_values), NA)
	_assert_value(no_values.ratio_sd(no_values), NA)


func test_ratio_with_baseline_mean_zero() -> void:
	var baseline := GdUnitBenchmarkStatistics.new(PackedFloat64Array([0.0, 0.0]))
	var statistics := GdUnitBenchmarkStatistics.new(PackedFloat64Array(SAMPLES_RESULT_MODEL))

	_assert_value(statistics.ratio(baseline), NA)
	_assert_value(statistics.ratio_sd(baseline), NA)
#endregion


func _generated_samples(count: int) -> PackedFloat64Array:
	var samples := PackedFloat64Array()
	for index: int in count:
		samples.append(1000.0 + (index * 37) % 23)
	return samples


func _assert_statistics(statistics: GdUnitBenchmarkStatistics, mean: float, error: float, stddev: float, median: float, minimum: float, maximum: float) -> void:
	_assert_value(statistics.mean, mean)
	_assert_value(statistics.error, error)
	_assert_value(statistics.stddev, stddev)
	_assert_value(statistics.median, median)
	_assert_value(statistics.minimum, minimum)
	_assert_value(statistics.maximum, maximum)


func _assert_value(actual: float, expected: float) -> void:
	if GdUnitBenchmarkStatistics.is_na(expected):
		assert_bool(GdUnitBenchmarkStatistics.is_na(actual)).is_true()
	else:
		assert_float(actual).is_equal_approx(expected, TOLERANCE)
