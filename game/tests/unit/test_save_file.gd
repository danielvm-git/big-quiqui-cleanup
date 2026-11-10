# story: e03s01
extends GutTest
## SaveFile writes JSON atomically and never throws a bad file at the game.

const PATH: String = "user://test_save_file.json"


func before_each() -> void:
	_remove(PATH)
	_remove(PATH + ".tmp")


func after_all() -> void:
	_remove(PATH)
	_remove(PATH + ".tmp")


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
