# story: e05s02
# story: e05s03
extends GutTest
## The export hygiene check and the version script catch what they must. They are shell scripts,
## so the tests run them and read the exit code.


func _run(script: String, args: Array[String]) -> Array:
	var root: String = ProjectSettings.globalize_path("res://").path_join("..")
	var output: Array = []
	var arguments: PackedStringArray = PackedStringArray([root.path_join("scripts").path_join(script)])
	arguments.append_array(PackedStringArray(args))
	var code: int = OS.execute("bash", arguments, output, true)
	return [code, "".join(output)]


func test_the_real_preset_is_clean() -> void:
	var result: Array = _run("check_export.sh", [])
	assert_eq(result[0], 0, str(result[1]))


func test_the_check_catches_every_planted_violation() -> void:
	var result: Array = _run("check_export.sh", ["--self-test"])
	assert_eq(result[0], 0, str(result[1]))
	assert_false(str(result[1]).contains("FAIL"))


func test_a_dirty_preset_fails_the_check() -> void:
	var path: String = "user://dirty_presets.cfg"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string('[preset.0]\nplatform="iOS"\napplication/app_store_team_id="ABCDE12345"\n')
	file.close()
	var result: Array = _run("check_export.sh", [ProjectSettings.globalize_path(path)])
	assert_eq(result[0], 1)
	assert_true(str(result[1]).contains("team id"))
	DirAccess.remove_absolute(path)


func test_the_version_comes_from_a_tag_shape() -> void:
	var result: Array = _run("version.sh", ["--self-test"])
	assert_eq(result[0], 0, str(result[1]))
	var plain: Array = _run("version.sh", [])
	assert_true(RegEx.create_from_string("^[0-9]+\\.[0-9]+\\.[0-9]+\\s*$").search(str(plain[1])) != null)
