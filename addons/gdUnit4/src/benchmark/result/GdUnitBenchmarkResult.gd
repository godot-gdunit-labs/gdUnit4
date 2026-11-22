class_name GdUnitBenchmarkResult
extends RefCounted

enum State {
	MEASURED,
	FAILED,
	SKIPPED,
}

const STATE_NAMES: Array[String] = ["measured", "failed", "skipped"]
const JSON_TYPES: Array[int] = [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING]

var suite := ""
var benchmark := ""
var display_name := ""
var parameters := {}
var baseline := false
var is_async := false
var state := State.MEASURED
var error := ""
var n := 0
var rounds := 0
var warmup := 0
var overhead_ns := GdUnitBenchmarkStatistics.NA
var ratio := GdUnitBenchmarkStatistics.NA
var ratio_sd := GdUnitBenchmarkStatistics.NA
var hints := PackedStringArray()
var _samples := PackedFloat64Array()
var _statistics := GdUnitBenchmarkStatistics.new()


func samples() -> PackedFloat64Array:
	return _samples


func statistics() -> GdUnitBenchmarkStatistics:
	return _statistics


func set_samples(values: PackedFloat64Array) -> void:
	_samples = values.duplicate()
	_statistics = GdUnitBenchmarkStatistics.new(_samples)


func serialize() -> Dictionary:
	var serialized_parameters := _serialize_parameters()
	return {
		"suite": suite,
		"benchmark": benchmark,
		"display_name": display_name,
		"parameters": serialized_parameters,
		"parameter_types": _parameter_types(serialized_parameters),
		"baseline": baseline,
		"async": is_async,
		"state": STATE_NAMES[state],
		"error": error,
		"n": n,
		"rounds": rounds,
		"warmup": warmup,
		"overhead_ns": serialize_float(overhead_ns),
		"samples_ns": Array(_samples),
		"outliers_ns": Array(_statistics.outliers),
		"mean_ns": serialize_float(_statistics.mean),
		"error_ns": serialize_float(_statistics.error),
		"stddev_ns": serialize_float(_statistics.stddev),
		"median_ns": serialize_float(_statistics.median),
		"min_ns": serialize_float(_statistics.minimum),
		"max_ns": serialize_float(_statistics.maximum),
		"ratio": serialize_float(ratio),
		"ratio_sd": serialize_float(ratio_sd),
		"hints": Array(hints),
	}


static func deserialize(serialized: Dictionary) -> GdUnitBenchmarkResult:
	var result := GdUnitBenchmarkResult.new()
	result.suite = serialized.get("suite", "")
	result.benchmark = serialized.get("benchmark", "")
	result.display_name = serialized.get("display_name", "")
	var types: Dictionary = serialized.get("parameter_types", {})
	var values: Dictionary = serialized.get("parameters", {})
	for key: Variant in values:
		var type: int = types.get(key, typeof(values[key]))
		result.parameters[key] = _deserialize_parameter(values[key], type)
	result.baseline = serialized.get("baseline", false)
	result.is_async = serialized.get("async", false)
	result.state = maxi(STATE_NAMES.find(serialized.get("state", "")), State.MEASURED) as State
	result.error = serialized.get("error", "")
	result.n = serialized.get("n", 0)
	result.rounds = serialized.get("rounds", 0)
	result.warmup = serialized.get("warmup", 0)
	result.overhead_ns = deserialize_float(serialized.get("overhead_ns"))
	var samples_ns: Array = serialized.get("samples_ns", [])
	result.set_samples(PackedFloat64Array(samples_ns))
	result.ratio = deserialize_float(serialized.get("ratio"))
	result.ratio_sd = deserialize_float(serialized.get("ratio_sd"))
	var serialized_hints: Array = serialized.get("hints", [])
	result.hints = PackedStringArray(serialized_hints)
	return result


static func serialize_float(value: float) -> Variant:
	if GdUnitBenchmarkStatistics.is_na(value):
		return null
	return value


static func deserialize_float(value: Variant) -> float:
	if value == null:
		return GdUnitBenchmarkStatistics.NA
	var number: float = value
	return number


func _serialize_parameters() -> Dictionary:
	var serialized := {}
	for key: Variant in parameters:
		var value: Variant = parameters[key]
		serialized[key] = value if typeof(value) in JSON_TYPES else str(value)
	return serialized


static func _parameter_types(serialized_parameters: Dictionary) -> Dictionary:
	var types := {}
	for key: Variant in serialized_parameters:
		types[key] = typeof(serialized_parameters[key])
	return types


static func _deserialize_parameter(value: Variant, type: int) -> Variant:
	match type:
		TYPE_INT:
			var integer: int = value
			return integer
		TYPE_FLOAT:
			var number: float = value
			return number
		_:
			return value
