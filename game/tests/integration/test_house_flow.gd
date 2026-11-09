# story: e02s07
extends GutTest
## The whole house, end to end through Boot: map, five rooms, back to the map each time.

const ROOMS: Array[String] = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]


func _boot(size: Vector2i = Vector2i(1920, 1080)) -> Boot:
	var holder: Control = Control.new()
	holder.size = Vector2(size)
	add_child_autofree(holder)
	var boot: Boot = (load("res://scenes/boot.tscn") as PackedScene).instantiate() as Boot
	boot.beat_sec = 0.0
	boot.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(boot)
	await get_tree().process_frame
	return boot


func _solve_room(player: Player) -> void:
	var guard: int = 0
	while player.scene_player.state() == ScenePlayer.STEP and guard < 10:
		var step: StepDef = player.scene_player.current_step()
		StepSolver.solve(player.template(), step.params)
		guard += 1


func test_boot_opens_the_map() -> void:
	var boot: Boot = await _boot()
	assert_eq(boot.player.scene_id, "house_map")
	assert_true(boot.player.template() is MapTemplate)


func test_a_chosen_room_opens_and_home_returns_to_the_map() -> void:
	var boot: Boot = await _boot()
	(boot.player.template() as MapTemplate).choose_room("kitchen")
	await get_tree().process_frame
	assert_eq(boot.player.scene_id, "kitchen")
	boot.player.go_home()
	await get_tree().process_frame
	assert_eq(boot.player.scene_id, "house_map")
	assert_false(boot.house.is_clean("kitchen"))


func test_every_room_can_be_cleaned_and_the_map_shows_it() -> void:
	var boot: Boot = await _boot()
	for room: String in ROOMS:
		(boot.player.template() as MapTemplate).choose_room(room)
		await get_tree().process_frame
		assert_eq(boot.player.scene_id, room)
		_solve_room(boot.player)
		assert_eq(boot.player.scene_player.state(), ScenePlayer.OUTRO, room)
		boot.player.outro_button.pressed.emit()
		await get_tree().process_frame
		assert_eq(boot.player.scene_id, "house_map")
		assert_true((boot.player.template() as MapTemplate).is_clean(room), room)
	assert_true(boot.house.all_clean())


func test_a_clean_room_can_be_played_again_from_the_map() -> void:
	var boot: Boot = await _boot()
	(boot.player.template() as MapTemplate).choose_room("garden")
	await get_tree().process_frame
	_solve_room(boot.player)
	boot.player.outro_button.pressed.emit()
	await get_tree().process_frame
	(boot.player.template() as MapTemplate).choose_room("garden")
	await get_tree().process_frame
	assert_eq(boot.player.scene_player.state(), ScenePlayer.STEP)
	assert_true(boot.house.is_clean("garden"))


func test_every_scene_passes_the_oracle_on_every_size_at_start_and_at_the_outro() -> void:
	for size: Vector2i in GeometryOracle.SIZES:
		var boot: Boot = await _boot(size)
		for room: String in ["house_map"] + ROOMS:
			if room != "house_map":
				(boot.player.template() as MapTemplate).choose_room(room)
				await get_tree().process_frame
			var holder: Control = boot.get_parent() as Control
			assert_eq(GeometryOracle.audit(holder, size), [] as Array[String], "%s %s start" % [room, size])
			if room == "house_map":
				continue
			_solve_room(boot.player)
			assert_eq(GeometryOracle.audit(holder, size), [] as Array[String], "%s %s outro" % [room, size])
			boot.player.outro_button.pressed.emit()
			await get_tree().process_frame
