# story: e01s07
extends GutTest
## The living room is data: it validates, every file it names exists, and only two .tscn files exist.

const PATH: String = "res://data/scenes/living_room.tres"


func _scene() -> SceneDef:
	return load(PATH) as SceneDef


func test_the_scene_validates() -> void:
	assert_eq(_scene().validate().size(), 0)


func test_background_and_music_exist() -> void:
	assert_not_null(Assets.texture(_scene().background))
	assert_not_null(Assets.sound(_scene().music))


func test_every_reaction_asset_exists() -> void:
	for step: StepDef in _scene().steps:
		for reaction: Reaction in step.on_hit + step.on_miss:
			match reaction.kind:
				"sfx":
					assert_not_null(Assets.sound("sfx/" + reaction.value), reaction.value)
				"pose":
					assert_not_null(Assets.texture("quiqui/" + reaction.value), reaction.value)
				"fx":
					assert_not_null(Assets.texture("effects/" + reaction.value), reaction.value)


func test_every_toy_has_art_and_a_home() -> void:
	var params: Dictionary = _scene().steps[1].params
	for id: String in params["items"] as Array:
		assert_not_null(Assets.texture("items/" + id), id)
		assert_true((params["homes"] as Dictionary).has(id), id)


func test_the_outro_art_exists() -> void:
	assert_not_null(Assets.texture("quiqui/" + Player.OUTRO_POSE))
	assert_not_null(Assets.texture("ui/play_button"))
	assert_not_null(Assets.texture("ui/home_button"))


func test_the_layers_fit_the_design_screen() -> void:
	var screen: Rect2 = Rect2(0, 0, 1920, 1080)
	assert_true(screen.encloses(_scene().steps[0].params["layer_rect"] as Rect2))
	assert_true(screen.encloses(_scene().steps[1].params["target_rect"] as Rect2))


func test_only_two_tscn_files_exist() -> void:
	var found: Array[String] = []
	_collect("res://scenes", found)
	_collect("res://data", found)
	found.sort()
	assert_eq(found, ["boot.tscn", "player.tscn"] as Array[String])


func _collect(dir_path: String, found: Array[String]) -> void:
	for file: String in DirAccess.get_files_at(dir_path):
		if file.ends_with(".tscn"):
			found.append(file)
