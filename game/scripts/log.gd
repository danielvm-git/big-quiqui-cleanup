class_name Log
extends RefCounted
## Structured logging for developers: one JSON object per line on stdout.
## It is on only in debug builds, writes no file and sends nothing anywhere (ADR-004:
## no telemetry). Never pass a name, a path or anything a child or parent typed.

const FIXED: Array[String] = ["level", "timestamp", "message"]

static var enabled: bool = OS.is_debug_build()


static func info(message: String, context: Dictionary = {}) -> String:
	return _emit("info", message, context)


static func error(message: String, context: Dictionary = {}) -> String:
	return _emit("error", message, context)


static func format(level: String, message: String, context: Dictionary) -> String:
	var entry: Dictionary = {}
	for key: Variant in context:
		if not FIXED.has(str(key)):
			entry[str(key)] = context[key]
	entry["level"] = level
	entry["timestamp"] = Time.get_datetime_string_from_system(true) + "Z"
	entry["message"] = message
	return JSON.stringify(entry)


static func _emit(level: String, message: String, context: Dictionary) -> String:
	if not enabled:
		return ""
	var line: String = format(level, message, context)
	print(line)
	return line
