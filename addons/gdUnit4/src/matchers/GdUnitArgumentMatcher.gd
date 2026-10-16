class_name GdUnitArgumentMatcher
extends RefCounted
## The base class of all argument matchers


@warning_ignore("unused_parameter")
func is_match(_value: Variant) -> bool:
	return true


func _to_string() -> String:
	assert(false, "`_to_string()` Is not implemented!")
	return ""
