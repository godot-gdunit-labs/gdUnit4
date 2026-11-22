class_name GdUnitBenchmarkStatistics
extends RefCounted

const NA := NAN
const OUTLIER_FENCE_FACTOR := 1.5
const T_ABOVE_TABLE := 3.291
const T_TABLE: Array[float] = [
	636.619, 31.599, 12.924, 8.610, 6.869, 5.959, 5.408, 5.041, 4.781, 4.587,
	4.437, 4.318, 4.221, 4.140, 4.073, 4.015, 3.965, 3.922, 3.883, 3.850,
	3.819, 3.792, 3.768, 3.745, 3.725, 3.707, 3.690, 3.674, 3.659, 3.646,
]

var mean := NA
var error := NA
var stddev := NA
var median := NA
var minimum := NA
var maximum := NA
var outliers := PackedFloat64Array()


func _init(samples := PackedFloat64Array()) -> void:
	if samples.is_empty():
		return
	var sorted_samples := samples.duplicate()
	sorted_samples.sort()
	var lower_quartile := _quantile(sorted_samples, 0.25)
	var upper_quartile := _quantile(sorted_samples, 0.75)
	var upper_fence := upper_quartile + OUTLIER_FENCE_FACTOR * (upper_quartile - lower_quartile)
	for sample: float in samples:
		if sample > upper_fence:
			outliers.append(sample)
	var values := sorted_samples.slice(0, sorted_samples.bsearch(upper_fence, false))
	var count := values.size()
	var sum := 0.0
	for value: float in values:
		sum += value
	mean = sum / count
	median = _quantile(values, 0.5)
	minimum = values[0]
	maximum = values[count - 1]
	if count < 2:
		return
	var squared_deviations := 0.0
	for value: float in values:
		squared_deviations += (value - mean) * (value - mean)
	stddev = sqrt(squared_deviations / (count - 1))
	error = t_quantile(count - 1) * stddev / sqrt(count)


static func is_na(value: float) -> bool:
	return is_nan(value)


static func t_quantile(degrees_of_freedom: int) -> float:
	if degrees_of_freedom < 1:
		return NA
	if degrees_of_freedom > T_TABLE.size():
		return T_ABOVE_TABLE
	return T_TABLE[degrees_of_freedom - 1]


static func _quantile(sorted_values: PackedFloat64Array, probability: float) -> float:
	var position := probability * (sorted_values.size() - 1)
	var lower := floori(position)
	var upper := mini(lower + 1, sorted_values.size() - 1)
	return lerpf(sorted_values[lower], sorted_values[upper], position - lower)


func ratio(baseline: GdUnitBenchmarkStatistics) -> float:
	if is_na(mean) or is_na(baseline.mean) or baseline.mean == 0.0:
		return NA
	if baseline == self:
		return 1.0
	return mean / baseline.mean


func ratio_sd(baseline: GdUnitBenchmarkStatistics) -> float:
	var current_ratio := ratio(baseline)
	if is_na(current_ratio) or is_na(stddev) or is_na(baseline.stddev):
		return NA
	if baseline == self:
		return 0.0
	return current_ratio * sqrt(pow(stddev / mean, 2) + pow(baseline.stddev / baseline.mean, 2))
