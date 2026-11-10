# story: e04s05
extends GutTest
## The game opens on the title. Play leads to the map. The parent area can reset progress.

const SAVE: String = TestReset.TEST_SAVE_PATH


func before_each() -> void:
	TestReset.delete_test_save()


func after_all() -> void:
	TestReset.delete_test_save()


func _boot(size: Vector2i = Vector2i(1920, 1080)) -> Boot:
	var holder: Control = Control.new()
	holder.size = Vector2(size)
	add_child_autofree(holder)
	var boot: Boot = (load("res://scenes/boot.tscn") as PackedScene).instantiate() as Boot
	boot.beat_sec = 0.0
	boot.save_path = SAVE
	boot.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(boot)
	await get_tree().process_frame
	return boot


func _press(view: Control, pressed: bool) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.pressed = pressed
	event.position = Vector2(10, 10)
	view.gui_input.emit(event)


func test_the_title_scene_is_data_that_validates() -> void:
	var def: SceneDef = load("res://data/scenes/title.tres") as SceneDef
	assert_eq(def.validate().size(), 0)
	assert_eq(def.steps[0].template, "t0_title")
	assert_false(def.show_outro)
	assert_eq(def.next, "house_map")
	assert_not_null(Assets.texture(def.background))
	assert_not_null(Assets.texture("ui/lock"))


func test_the_game_opens_on_the_title() -> void:
	var boot: Boot = await _boot()
	assert_eq(boot.player.scene_id, "title")
	assert_true(boot.player.template() is TitleTemplate)
	assert_false(boot.player.home_button.visible)
	assert_false(boot.player.meter.visible)


func test_play_leads_straight_to_the_map_with_no_second_button() -> void:
	var boot: Boot = await _boot()
	(boot.player.template() as TitleTemplate).play()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(boot.player.scene_id, "house_map")


func test_the_title_passes_the_oracle_on_every_size() -> void:
	for size: Vector2i in GeometryOracle.SIZES:
		var boot: Boot = await _boot(size)
		assert_eq(GeometryOracle.audit(boot.get_parent() as Control, size), [] as Array[String], str(size))


func test_the_parent_area_resets_progress_and_the_house() -> void:
	var saved: Progress = Progress.new()
	saved.mark_clean("kitchen")
	saved.add_coins(7)
	saved.save_to(SAVE)
	var boot: Boot = await _boot()
	assert_true(boot.house.is_clean("kitchen"))
	var view: TitleView = boot.player.stage.get_child(0) as TitleView
	_press(view.lock_button, true)
	for tick: int in 60:
		view._process(0.05)
	assert_true(view.panel.visible)
	view.panel.reset_button.pressed.emit()
	view.panel.reset_button.pressed.emit()
	assert_eq(boot.progress.coins, 0)
	assert_eq(boot.house.clean_count(), 0)
	assert_eq(int(SaveFile.read(SAVE)["coins"]), 0)
	assert_eq((SaveFile.read(SAVE)["clean"] as Array).size(), 0)


func test_a_child_tapping_the_lock_never_reaches_the_parent_area() -> void:
	var boot: Boot = await _boot()
	var view: TitleView = boot.player.stage.get_child(0) as TitleView
	for tap: int in 100:
		_press(view.lock_button, true)
		view._process(0.1)
		_press(view.lock_button, false)
	assert_false(view.panel.visible)
