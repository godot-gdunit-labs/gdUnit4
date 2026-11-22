class_name GdUnitBenchmarkTestHelper
extends RefCounted


static func json_round_trip(serialized: Dictionary) -> Dictionary:
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(serialized, "", false, true))
	return parsed
