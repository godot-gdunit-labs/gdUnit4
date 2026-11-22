class_name GdUnitBenchmarkEvent
extends RefCounted

enum Type {
	SESSION_START,
	SUITE_BEFORE,
	BENCHMARK_BEFORE,
	BENCHMARK_AFTER,
	SUITE_AFTER,
	SESSION_CLOSE,
}

var type := Type.SESSION_START
var suite := ""
var guid := ""
var environment: GdUnitBenchmarkEnvironment
var result: GdUnitBenchmarkResult


func _init(event_type := Type.SESSION_START, suite_path := "", test_guid := "") -> void:
	type = event_type
	suite = suite_path
	guid = test_guid


static func session_start(session_environment: GdUnitBenchmarkEnvironment) -> GdUnitBenchmarkEvent:
	var event := GdUnitBenchmarkEvent.new(Type.SESSION_START)
	event.environment = session_environment
	return event


static func suite_before(suite_path: String) -> GdUnitBenchmarkEvent:
	return GdUnitBenchmarkEvent.new(Type.SUITE_BEFORE, suite_path)


static func benchmark_before(suite_path: String, test_guid: GdUnitGUID) -> GdUnitBenchmarkEvent:
	return GdUnitBenchmarkEvent.new(Type.BENCHMARK_BEFORE, suite_path, str(test_guid))


static func benchmark_after(suite_path: String, test_guid: GdUnitGUID, benchmark_result: GdUnitBenchmarkResult) -> GdUnitBenchmarkEvent:
	var event := GdUnitBenchmarkEvent.new(Type.BENCHMARK_AFTER, suite_path, str(test_guid))
	event.result = benchmark_result
	return event


static func suite_after(suite_path: String) -> GdUnitBenchmarkEvent:
	return GdUnitBenchmarkEvent.new(Type.SUITE_AFTER, suite_path)


static func session_close() -> GdUnitBenchmarkEvent:
	return GdUnitBenchmarkEvent.new(Type.SESSION_CLOSE)


func serialize() -> Dictionary:
	var serialized := {
		"type": type,
		"suite": suite,
		"guid": guid,
	}
	if environment != null:
		serialized["environment"] = environment.serialize()
	if result != null:
		serialized["result"] = result.serialize()
	return serialized


static func deserialize(serialized: Dictionary) -> GdUnitBenchmarkEvent:
	var event_type: int = serialized.get("type", Type.SESSION_START)
	var suite_path: String = serialized.get("suite", "")
	var test_guid: String = serialized.get("guid", "")
	var event := GdUnitBenchmarkEvent.new(clampi(event_type, Type.SESSION_START, Type.SESSION_CLOSE) as Type, suite_path, test_guid)
	if serialized.has("environment"):
		var serialized_environment: Dictionary = serialized["environment"]
		event.environment = GdUnitBenchmarkEnvironment.deserialize(serialized_environment)
	if serialized.has("result"):
		var serialized_result: Dictionary = serialized["result"]
		event.result = GdUnitBenchmarkResult.deserialize(serialized_result)
	return event
