# story: e01s02
extends GutTest
## The scene data model validates itself and reports every problem as a string.


func _step(template: String = "t23_erase") -> StepDef:
	var step: StepDef = StepDef.new()
	step.template = template
	return step


func _scene() -> SceneDef:
	var scene: SceneDef = SceneDef.new()
	scene.id = "living_room"
	scene.steps = [_step()] as Array[StepDef]
	return scene


func test_valid_scene_has_no_errors() -> void:
	assert_eq(_scene().validate().size(), 0)


func test_empty_id_is_an_error() -> void:
	var scene: SceneDef = _scene()
	scene.id = ""
	assert_gt(scene.validate().size(), 0)


func test_scene_without_steps_is_an_error() -> void:
	var scene: SceneDef = _scene()
	scene.steps = [] as Array[StepDef]
	assert_gt(scene.validate().size(), 0)


func test_unknown_template_is_an_error() -> void:
	var scene: SceneDef = _scene()
	scene.steps = [_step("t99_nope")] as Array[StepDef]
	assert_string_contains(scene.validate()[0], "t99_nope")


func test_unknown_reaction_kind_is_an_error() -> void:
	var scene: SceneDef = _scene()
	var reaction: Reaction = Reaction.new()
	reaction.kind = "explode"
	scene.steps[0].on_hit = [reaction] as Array[Reaction]
	assert_string_contains(scene.validate()[0], "explode")


func test_every_declared_kind_is_valid() -> void:
	for kind: String in Reaction.KINDS:
		var reaction: Reaction = Reaction.new()
		reaction.kind = kind
		assert_eq(reaction.validate().size(), 0, kind)


func test_tres_round_trip_keeps_the_data() -> void:
	var path: String = "user://scene_round_trip.tres"
	assert_eq(ResourceSaver.save(_scene(), path), OK)
	var loaded: SceneDef = load(path) as SceneDef
	assert_eq(loaded.id, "living_room")
	assert_eq(loaded.steps[0].template, "t23_erase")
	DirAccess.remove_absolute(path)
