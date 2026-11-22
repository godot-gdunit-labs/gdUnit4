class_name GdUnitBenchmarkEnvironment
extends RefCounted

var gdunit4_version := ""
var godot_version := ""
var editor_build := false
var debug_build := false
var os_name := ""
var os_version := ""
var processor_name := ""
var processor_count := 0
var headless := false
var debugger_active := false
var time := ""


static func current() -> GdUnitBenchmarkEnvironment:
	var environment := GdUnitBenchmarkEnvironment.new()
	environment.gdunit4_version = str(GdUnit4Version.current())
	environment.godot_version = _godot_version(Engine.get_version_info())
	environment.editor_build = OS.has_feature("editor")
	environment.debug_build = OS.is_debug_build()
	environment.os_name = OS.get_name()
	environment.os_version = OS.get_version()
	environment.processor_name = OS.get_processor_name()
	environment.processor_count = OS.get_processor_count()
	environment.headless = DisplayServer.get_name() == "headless"
	environment.debugger_active = EngineDebugger.is_active()
	environment.time = Time.get_datetime_string_from_system(true)
	return environment


func serialize() -> Dictionary:
	return {
		"gdunit4": gdunit4_version,
		"godot": godot_version,
		"editor": editor_build,
		"debug": debug_build,
		"os": os_name,
		"os_version": os_version,
		"cpu": processor_name,
		"cpu_count": processor_count,
		"headless": headless,
		"debugger": debugger_active,
		"time": time,
	}


static func deserialize(serialized: Dictionary) -> GdUnitBenchmarkEnvironment:
	var environment := GdUnitBenchmarkEnvironment.new()
	environment.gdunit4_version = serialized.get("gdunit4", "")
	environment.godot_version = serialized.get("godot", "")
	environment.editor_build = serialized.get("editor", false)
	environment.debug_build = serialized.get("debug", false)
	environment.os_name = serialized.get("os", "")
	environment.os_version = serialized.get("os_version", "")
	environment.processor_name = serialized.get("cpu", "")
	environment.processor_count = serialized.get("cpu_count", 0)
	environment.headless = serialized.get("headless", false)
	environment.debugger_active = serialized.get("debugger", false)
	environment.time = serialized.get("time", "")
	return environment


static func _godot_version(info: Dictionary) -> String:
	return "v%d.%d.%d.%s" % [info.get("major", 0), info.get("minor", 0), info.get("patch", 0), info.get("status", "")]
