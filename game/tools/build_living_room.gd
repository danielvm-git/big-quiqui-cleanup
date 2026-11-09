extends SceneTree
## Writes data/scenes/living_room.tres. Run: godot --headless --path game -s res://tools/build_living_room.gd


func _init() -> void:
	var scene: SceneDef = SceneDef.new()
	scene.id = "living_room"
	scene.background = "backgrounds/living_room"
	scene.music = "music/main_theme"
	scene.quiqui_pose = "idle"
	scene.steps = [_wipe_step(), _toys_step()] as Array[StepDef]
	var errors: PackedStringArray = scene.validate()
	if not errors.is_empty():
		push_error(str(errors))
		quit(1)
		return
	quit(ResourceSaver.save(scene, "res://data/scenes/living_room.tres"))


func _reaction(kind: String, value: String) -> Reaction:
	var reaction: Reaction = Reaction.new()
	reaction.kind = kind
	reaction.value = value
	return reaction


func _wipe_step() -> StepDef:
	var step: StepDef = StepDef.new()
	step.template = "t23_erase"
	step.params = {
		"tool": "sponge",
		"layer_rect": Rect2(300, 760, 1300, 320),
		"cell": 20.0,
		"radius": 60.0,
		"threshold": 0.9,
		"levels": 1,
	}
	step.on_hit = [_reaction("sfx", "bubble"), _reaction("pose", "laugh")] as Array[Reaction]
	return step


func _toys_step() -> StepDef:
	var step: StepDef = StepDef.new()
	step.template = "t20_drag_snap"
	step.params = {
		"items": ["ball", "plush", "toy_duck"],
		"homes": {"ball": Vector2(980, 860), "plush": Vector2(1180, 940), "toy_duck": Vector2(800, 960)},
		"target_rect": Rect2(430, 300, 320, 500),
	}
	step.on_hit = (
		[_reaction("sfx", "success"), _reaction("pose", "jump"), _reaction("fx", "sparkle")] as Array[Reaction]
	)
	step.on_miss = [_reaction("sfx", "soft_miss"), _reaction("pose", "idle")] as Array[Reaction]
	return step
