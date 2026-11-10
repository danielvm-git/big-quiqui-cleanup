# story: e03s02
extends GutTest
## Progress is what the house remembers: clean rooms and coins. Schema version 1.

const PATH: String = "user://test_progress_unit.json"


func after_each() -> void:
	for path: String in [PATH, PATH + ".tmp", PATH + ".bak", PATH + ".corrupt"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func test_a_new_progress_is_empty() -> void:
	var progress: Progress = Progress.new()
	assert_eq(progress.coins, 0)
	assert_eq(progress.clean.size(), 0)


func test_coins_add_up_and_never_go_down() -> void:
	var progress: Progress = Progress.new()
	progress.add_coins(2)
	progress.add_coins(-5)
	progress.add_coins(1)
	assert_eq(progress.coins, 3)


func test_a_room_is_recorded_once() -> void:
	var progress: Progress = Progress.new()
	progress.mark_clean("kitchen")
	progress.mark_clean("kitchen")
	assert_eq(progress.clean, ["kitchen"] as Array[String])


func test_it_survives_the_disk() -> void:
	var progress: Progress = Progress.new()
	progress.mark_clean("kitchen")
	progress.add_coins(4)
	assert_true(progress.save_to(PATH))
	var loaded: Progress = Progress.load_from(PATH)
	assert_eq(loaded.coins, 4)
	assert_eq(loaded.clean, ["kitchen"] as Array[String])


func test_a_missing_file_gives_a_fresh_progress() -> void:
	var loaded: Progress = Progress.load_from(PATH)
	assert_eq(loaded.coins, 0)
	assert_eq(loaded.clean.size(), 0)


func test_an_unknown_version_gives_a_fresh_progress() -> void:
	var loaded: Progress = Progress.from_dict({"version": 99, "coins": 7, "clean": ["kitchen"]})
	assert_eq(loaded.coins, 0)
	assert_eq(loaded.clean.size(), 0)


func test_wrong_types_give_nothing_for_that_field() -> void:
	assert_eq(Progress.from_dict({"version": 1, "coins": "many", "clean": ["kitchen"]}).coins, 0)
	assert_eq(Progress.from_dict({"version": 1, "coins": 3, "clean": "kitchen"}).clean.size(), 0)
	assert_eq(Progress.from_dict({"version": 1, "coins": 3, "clean": [1, 2]}).clean.size(), 0)


func test_a_version_of_the_wrong_type_gives_a_fresh_progress() -> void:
	assert_eq(Progress.from_dict({"version": [1], "coins": 3, "clean": []}).coins, 0)


func test_negative_saved_coins_are_not_trusted() -> void:
	assert_eq(Progress.from_dict({"version": 1, "coins": -4, "clean": []}).coins, 0)


func test_it_seeds_a_house_and_ignores_unknown_rooms() -> void:
	var progress: Progress = Progress.new()
	progress.mark_clean("kitchen")
	progress.mark_clean("attic")
	var house: HouseState = HouseState.new(["living_room", "kitchen"] as Array[String])
	progress.apply_to(house)
	assert_true(house.is_clean("kitchen"))
	assert_eq(house.clean_count(), 1)


func test_a_huge_coin_count_is_capped_not_wrapped() -> void:
	var loaded: Progress = Progress.from_dict({"version": 1, "coins": 1e30, "clean": ["kitchen"]})
	assert_eq(loaded.coins, Progress.MAX_COINS)
	loaded.add_coins(1)
	assert_eq(loaded.coins, Progress.MAX_COINS)


func test_a_fraction_or_nan_is_not_trusted() -> void:
	assert_eq(Progress.from_dict({"version": 1, "coins": 2.5, "clean": []}).coins, 2)
	assert_eq(Progress.from_dict({"version": 1, "coins": NAN, "clean": []}).coins, 0)


func test_one_bad_field_does_not_discard_the_good_one() -> void:
	var loaded: Progress = Progress.from_dict({"version": 1, "coins": "many", "clean": ["kitchen", 5, "garden"]})
	assert_eq(loaded.coins, 0)
	assert_eq(loaded.clean, ["kitchen", "garden"] as Array[String])


func test_the_clean_list_is_capped() -> void:
	var rooms: Array = []
	for index: int in 1000:
		rooms.append("room_%d" % index)
	assert_eq(Progress.from_dict({"version": 1, "coins": 0, "clean": rooms}).clean.size(), Progress.MAX_ROOMS)


func test_an_unreadable_save_is_kept_aside_not_overwritten() -> void:
	var file: FileAccess = FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string('{"version": 2, "coins": 5, "clean": []}')
	file.close()
	assert_true(Progress.keep_unreadable(PATH))
	assert_false(FileAccess.file_exists(PATH))
	assert_true(FileAccess.file_exists(PATH + ".corrupt"))


func test_a_good_or_missing_save_is_left_alone() -> void:
	assert_false(Progress.keep_unreadable(PATH))
	Progress.new().save_to(PATH)
	assert_false(Progress.keep_unreadable(PATH))
	assert_true(FileAccess.file_exists(PATH))
