# story: e03s02
extends GutTest
## Progress is what the house remembers: clean rooms and coins. Schema version 1.

const PATH: String = "user://test_progress.json"


func after_each() -> void:
	for path: String in [PATH, PATH + ".tmp"]:
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


func test_wrong_types_give_a_fresh_progress() -> void:
	assert_eq(Progress.from_dict({"version": 1, "coins": "many", "clean": ["kitchen"]}).clean.size(), 0)
	assert_eq(Progress.from_dict({"version": 1, "coins": 3, "clean": "kitchen"}).coins, 0)
	assert_eq(Progress.from_dict({"version": 1, "coins": 3, "clean": [1, 2]}).coins, 0)


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
