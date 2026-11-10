# story: e03s05
extends GutTest
## Close and open again: the house remembers. A bad save never stops the game.

const SAVE: String = TestReset.TEST_SAVE_PATH


func before_each() -> void:
	TestReset.delete_test_save()


func after_all() -> void:
	TestReset.delete_test_save()


func _boot() -> Boot:
	var holder: Control = Control.new()
	holder.size = Vector2(1920, 1080)
	add_child_autofree(holder)
	var boot: Boot = (load("res://scenes/boot.tscn") as PackedScene).instantiate() as Boot
	boot.beat_sec = 0.0
	boot.save_path = SAVE
	boot.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(boot)
	await get_tree().process_frame
	return boot


func _clean_kitchen_and_collect(boot: Boot) -> void:
	(boot.player.template() as MapTemplate).choose_room("kitchen")
	await get_tree().process_frame
	for step: StepDef in boot.player.scene_player.scene.steps:
		StepSolver.solve(boot.player.template(), step.params)
	boot.player.outro_button.pressed.emit()
	await get_tree().process_frame
	StepSolver.solve(boot.player.template(), boot.player.scene_player.current_step().params)
	boot.player.outro_button.pressed.emit()
	await get_tree().process_frame


func test_a_first_start_is_a_fresh_house() -> void:
	var boot: Boot = await _boot()
	assert_eq(boot.progress.coins, 0)
	assert_eq(boot.house.clean_count(), 0)


func test_the_map_shows_a_saved_clean_room() -> void:
	var saved: Progress = Progress.new()
	saved.mark_clean("kitchen")
	saved.add_coins(7)
	saved.save_to(SAVE)
	var boot: Boot = await _boot()
	assert_eq(boot.progress.coins, 7)
	assert_true(boot.house.is_clean("kitchen"))
	assert_true((boot.player.template() as MapTemplate).is_clean("kitchen"))
	assert_false((boot.player.template() as MapTemplate).is_clean("garden"))


func test_progress_survives_closing_the_game() -> void:
	var first: Boot = await _boot()
	await _clean_kitchen_and_collect(first)
	assert_eq(first.progress.coins, 3)
	first.get_parent().queue_free()
	await get_tree().process_frame
	var second: Boot = await _boot()
	assert_eq(second.progress.coins, 3)
	assert_true((second.player.template() as MapTemplate).is_clean("kitchen"))


func test_a_corrupt_save_starts_fresh_and_the_game_runs() -> void:
	var file: FileAccess = FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string('{"version": 1, "coins": 4, "clean": ["kit')
	file.close()
	var boot: Boot = await _boot()
	assert_eq(boot.progress.coins, 0)
	assert_eq(boot.house.clean_count(), 0)
	assert_true(boot.player.template() is MapTemplate)


func test_a_saved_room_the_house_no_longer_has_is_ignored() -> void:
	var saved: Progress = Progress.new()
	saved.mark_clean("attic")
	saved.save_to(SAVE)
	var boot: Boot = await _boot()
	assert_eq(boot.house.clean_count(), 0)
