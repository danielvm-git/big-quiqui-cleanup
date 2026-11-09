# story: e01s01
extends GutTest
## TestReset removes the test save and never touches the production save.


func test_delete_test_save_removes_all_three_files() -> void:
	for suffix: String in ["", ".bak", ".tmp"]:
		var file: FileAccess = FileAccess.open(TestReset.TEST_SAVE_PATH + suffix, FileAccess.WRITE)
		file.store_string("x")
		file.close()
	TestReset.delete_test_save()
	for suffix: String in ["", ".bak", ".tmp"]:
		assert_false(FileAccess.file_exists(TestReset.TEST_SAVE_PATH + suffix))


func test_the_test_path_is_not_the_production_path() -> void:
	assert_ne(TestReset.TEST_SAVE_PATH, TestReset.PRODUCTION_SAVE_PATH)


func test_reset_all_does_not_crash_without_managers() -> void:
	TestReset.reset_all()
	assert_true(true)
