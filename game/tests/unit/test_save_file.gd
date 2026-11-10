# story: e03s01
extends GutTest
## SaveFile writes JSON atomically and never throws a bad file at the game.

const PATH: String = "user://test_save_file.json"
const SUFFIXES: Array[String] = ["", ".tmp", ".bak"]


func before_each() -> void:
	_clean()


func after_all() -> void:
	_clean()


func _clean() -> void:
	for suffix: String in SUFFIXES:
		_remove(PATH + suffix)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _write_raw(text: String) -> void:
	var file: FileAccess = FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_a_saved_dictionary_comes_back() -> void:
	assert_true(SaveFile.write(PATH, {"coins": 3, "rooms": ["kitchen"]}))
	var data: Dictionary = SaveFile.read(PATH)
	assert_eq(int(data["coins"]), 3)
	assert_eq(data["rooms"], ["kitchen"])


func test_a_missing_file_reads_as_empty() -> void:
	assert_eq(SaveFile.read(PATH), {})


func test_a_corrupt_file_reads_as_empty() -> void:
	_write_raw('{"coins": 3, "rooms": [')
	assert_eq(SaveFile.read(PATH), {})


func test_a_file_that_is_not_a_dictionary_reads_as_empty() -> void:
	_write_raw("[1, 2, 3]")
	assert_eq(SaveFile.read(PATH), {})


func test_writing_leaves_no_temporary_file() -> void:
	SaveFile.write(PATH, {"coins": 1})
	assert_false(FileAccess.file_exists(PATH + ".tmp"))


func test_a_second_write_replaces_the_first() -> void:
	SaveFile.write(PATH, {"coins": 1})
	SaveFile.write(PATH, {"coins": 2})
	assert_eq(int(SaveFile.read(PATH)["coins"]), 2)


func test_a_leftover_temporary_file_does_not_hurt() -> void:
	SaveFile.write(PATH, {"coins": 1})
	var file: FileAccess = FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	file.store_string("half a wri")
	file.close()
	assert_eq(int(SaveFile.read(PATH)["coins"]), 1)
	assert_true(SaveFile.write(PATH, {"coins": 5}))
	assert_eq(int(SaveFile.read(PATH)["coins"]), 5)


func test_an_unwritable_path_returns_false() -> void:
	assert_false(SaveFile.write("user://no_such_dir/x.json", {"a": 1}))


func test_a_successful_write_leaves_no_backup() -> void:
	SaveFile.write(PATH, {"coins": 1})
	SaveFile.write(PATH, {"coins": 2})
	assert_false(FileAccess.file_exists(PATH + ".bak"))


func test_a_lost_main_file_is_recovered_from_the_backup() -> void:
	SaveFile.write(PATH, {"coins": 1})
	DirAccess.rename_absolute(PATH, PATH + ".bak")
	assert_eq(int(SaveFile.read(PATH)["coins"]), 1)


func test_a_corrupt_main_file_is_recovered_from_the_backup() -> void:
	SaveFile.write(PATH, {"coins": 1})
	DirAccess.rename_absolute(PATH, PATH + ".bak")
	_write_raw("{broken")
	assert_eq(int(SaveFile.read(PATH)["coins"]), 1)


func test_a_failed_write_keeps_the_old_save() -> void:
	SaveFile.write(PATH, {"coins": 1})
	DirAccess.make_dir_absolute(PATH + ".tmp")
	assert_false(SaveFile.write(PATH, {"coins": 9}))
	DirAccess.remove_absolute(PATH + ".tmp")
	assert_eq(int(SaveFile.read(PATH)["coins"]), 1)


func test_a_huge_file_is_not_read() -> void:
	_write_raw('{"pad": "%s"}' % "x".repeat(SaveFile.MAX_BYTES))
	assert_eq(SaveFile.read(PATH), {})
