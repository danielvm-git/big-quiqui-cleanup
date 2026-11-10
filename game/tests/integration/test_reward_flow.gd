# story: e03s04
extends GutTest
## A cleaned room leads to the reward; collected stars become coins in Progress; the reward leads to the map.

const ROOMS: Array[String] = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]
const SAVE: String = TestReset.TEST_SAVE_PATH


func after_each() -> void:
	for path: String in [SAVE, SAVE + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _scene(id: String) -> SceneDef:
	return load("res://data/scenes/%s.tres" % id) as SceneDef


func _player(def: SceneDef, progress: Progress) -> Player:
	var player: Player = Player.new()
	player.def_override = def
	player.scene_id = def.id
	player.beat_sec = 0.0
	player.progress = progress
	player.save_path = SAVE
	player.size = Vector2(1920, 1080)
	add_child_autofree(player)
	return player


func _collect_all(player: Player) -> void:
	var template: StepTemplate = player.template()
	for id: String in (template as TouchEachTemplate).remaining():
		(template as TouchEachTemplate).touch(id)


func test_the_reward_scene_is_data_that_validates() -> void:
	var def: SceneDef = _scene("reward")
	assert_not_null(def)
	assert_eq(def.validate().size(), 0)
	assert_eq(def.steps[0].template, "t32_reward")
	assert_eq(def.next, "house_map")
	assert_not_null(Assets.texture(def.background))
	assert_not_null(Assets.sound(def.music))


func test_each_star_is_worth_one_coin_in_the_data() -> void:
	var coins: int = 0
	for reaction: Reaction in _scene("reward").steps[0].on_hit:
		if reaction.kind == "coins":
			coins += reaction.value.to_int()
		if reaction.kind == "sfx":
			assert_not_null(Assets.sound("sfx/" + reaction.value))
	assert_eq(coins, 1)


func test_every_room_leads_to_the_reward() -> void:
	for id: String in ROOMS:
		assert_eq(_scene(id).next, "reward", id)


func test_collecting_stars_adds_coins_and_saves() -> void:
	var progress: Progress = Progress.new()
	var player: Player = _player(_scene("reward"), progress)
	var template: TouchEachTemplate = player.template() as TouchEachTemplate
	template.touch(template.remaining()[0])
	assert_eq(progress.coins, 1)
	assert_eq(int(SaveFile.read(SAVE)["coins"]), 1)
	_collect_all(player)
	assert_eq(progress.coins, 3)
	assert_eq(int(SaveFile.read(SAVE)["coins"]), 3)


func test_without_progress_coins_are_harmless() -> void:
	var player: Player = _player(_scene("reward"), null)
	_collect_all(player)
	assert_eq(player.scene_player.state(), ScenePlayer.OUTRO)
	assert_false(FileAccess.file_exists(SAVE))


func test_a_cleaned_room_is_recorded_and_saved() -> void:
	var progress: Progress = Progress.new()
	var player: Player = _player(_scene("kitchen"), progress)
	player.house = HouseState.new(ROOMS)
	for step: StepDef in player.scene_player.scene.steps:
		StepSolver.solve(player.template(), step.params)
	assert_eq(player.scene_player.state(), ScenePlayer.OUTRO)
	assert_eq(progress.clean, ["kitchen"] as Array[String])
	assert_eq(SaveFile.read(SAVE)["clean"], ["kitchen"])


func test_a_room_not_finished_is_not_recorded() -> void:
	var progress: Progress = Progress.new()
	var player: Player = _player(_scene("kitchen"), progress)
	player.house = HouseState.new(ROOMS)
	player.go_home()
	assert_eq(progress.clean.size(), 0)


func test_the_reward_scene_is_never_a_clean_room() -> void:
	var progress: Progress = Progress.new()
	var player: Player = _player(_scene("reward"), progress)
	player.house = HouseState.new(ROOMS)
	_collect_all(player)
	assert_eq(progress.clean.size(), 0)


func test_the_whole_loop_goes_room_reward_map() -> void:
	var holder: Control = Control.new()
	holder.size = Vector2(1920, 1080)
	add_child_autofree(holder)
	var boot: Boot = (load("res://scenes/boot.tscn") as PackedScene).instantiate() as Boot
	boot.beat_sec = 0.0
	boot.save_path = SAVE
	boot.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(boot)
	await get_tree().process_frame
	(boot.player.template() as MapTemplate).choose_room("kitchen")
	await get_tree().process_frame
	for step: StepDef in boot.player.scene_player.scene.steps:
		StepSolver.solve(boot.player.template(), step.params)
	boot.player.outro_button.pressed.emit()
	await get_tree().process_frame
	assert_eq(boot.player.scene_id, "reward")
	assert_eq(GeometryOracle.audit(holder, Vector2i(1920, 1080)), [] as Array[String])
	_collect_all(boot.player)
	assert_eq(boot.progress.coins, 3)
	boot.player.outro_button.pressed.emit()
	await get_tree().process_frame
	assert_eq(boot.player.scene_id, "house_map")
	assert_true((boot.player.template() as MapTemplate).is_clean("kitchen"))
