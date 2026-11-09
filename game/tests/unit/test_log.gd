# story: e01s07
extends GutTest
## Structured logging: one JSON object per line, fixed fields, never on in a release build.


func test_a_line_is_json_with_the_fixed_fields() -> void:
	var line: String = Log.format("info", "step_started", {"index": 1})
	var parsed: Dictionary = JSON.parse_string(line) as Dictionary
	assert_eq(parsed["level"], "info")
	assert_eq(parsed["message"], "step_started")
	assert_eq(int(parsed["index"]), 1)
	assert_true(str(parsed["timestamp"]).ends_with("Z"))


func test_context_cannot_overwrite_the_fixed_fields() -> void:
	var line: String = Log.format("info", "real", {"message": "fake", "level": "fake"})
	var parsed: Dictionary = JSON.parse_string(line) as Dictionary
	assert_eq(parsed["message"], "real")
	assert_eq(parsed["level"], "info")


func test_a_line_has_no_newline() -> void:
	assert_false(Log.format("info", "a\nb", {}).contains("\n"))


func test_disabled_logging_prints_nothing_and_returns_empty() -> void:
	Log.enabled = false
	assert_eq(Log.info("quiet"), "")
	Log.enabled = OS.is_debug_build()
