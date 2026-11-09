# story: e02s07
extends GutTest
## The house is data: every scene validates, every file it names exists, everything fits the stage.

const SCENES: Array[String] = ["house_map", "living_room", "kitchen", "bathroom", "bedroom", "garden"]
const ROOMS: Array[String] = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]
const STAGE: Rect2 = Rect2(0, 0, 1920, 1080)


func _scene(id: String) -> SceneDef:
	return load("res://data/scenes/%s.tres" % id) as SceneDef


func test_every_scene_validates() -> void:
	for id: String in SCENES:
		assert_not_null(_scene(id), id)
		assert_eq(_scene(id).validate().size(), 0, id)
		assert_eq(_scene(id).id, id)


func test_every_scene_has_background_and_music() -> void:
	for id: String in SCENES:
		assert_not_null(Assets.texture(_scene(id).background), id)
		assert_not_null(Assets.sound(_scene(id).music), id)


func test_every_room_ends_at_the_map_and_the_map_lists_every_room() -> void:
	for id: String in ROOMS:
		assert_eq(_scene(id).next, "house_map", id)
	var ids: Array[String] = HouseState.from_map(_scene("house_map")).rooms
	assert_eq(ids, ROOMS)


func test_every_map_card_has_art_and_fits_the_stage() -> void:
	for room: Variant in _scene("house_map").steps[0].params["rooms"] as Array:
		var entry: Dictionary = room as Dictionary
		assert_not_null(Assets.texture(str(entry["art"])), str(entry["id"]))
		assert_true(STAGE.encloses(entry["rect"] as Rect2), str(entry["id"]))


func test_every_reaction_asset_exists() -> void:
	for id: String in SCENES:
		for step: StepDef in _scene(id).steps:
			for reaction: Reaction in step.on_hit + step.on_miss:
				_check_reaction(reaction, id)


func _check_reaction(reaction: Reaction, id: String) -> void:
	match reaction.kind:
		"sfx":
			assert_not_null(Assets.sound("sfx/" + reaction.value), id + ":" + reaction.value)
		"pose":
			assert_not_null(Assets.texture("quiqui/" + reaction.value), id + ":" + reaction.value)
		"fx":
			assert_not_null(Assets.texture("effects/" + reaction.value), id + ":" + reaction.value)


func test_every_step_fits_the_stage_and_has_its_art() -> void:
	for id: String in ROOMS:
		for step: StepDef in _scene(id).steps:
			_check_step(step, id)


func _check_step(step: StepDef, id: String) -> void:
	var params: Dictionary = step.params
	match step.template:
		"t23_erase":
			assert_true(STAGE.encloses(params["layer_rect"] as Rect2), id)
		"t20_drag_snap":
			assert_true(STAGE.encloses(params["target_rect"] as Rect2), id)
			for item: Variant in params["items"] as Array:
				assert_not_null(Assets.texture("items/" + str(item)), id + ":" + str(item))
				var home: Vector2 = (params["homes"] as Dictionary)[item] as Vector2
				assert_true(STAGE.encloses(_box(home, ToyView.TOY_SIZE)), id)
		"t21_touch_each":
			for target: Variant in params["targets"] as Array:
				assert_not_null(Assets.texture(str((params["art"] as Dictionary)[target])), id)
				var spot: Vector2 = (params["positions"] as Dictionary)[target] as Vector2
				assert_true(STAGE.encloses(_box(spot, TouchView.TARGET_SIZE)), id)


func test_the_rooms_vary_the_gesture() -> void:
	var templates: Dictionary = {}
	for id: String in ROOMS:
		for step: StepDef in _scene(id).steps:
			templates[step.template] = true
	assert_true(templates.has("t23_erase") and templates.has("t20_drag_snap") and templates.has("t21_touch_each"))


## The box a target occupies at its biggest (the pop and hint pulses reach 1.5x).
func _box(center: Vector2, size: Vector2) -> Rect2:
	return Rect2(center - size * 0.75, size * 1.5)
