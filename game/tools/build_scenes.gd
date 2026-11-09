extends SceneTree
## Writes every data/scenes/*.tres. Run: godot --headless --path game -s res://tools/build_scenes.gd
## The scenes are data: edit the numbers here, rerun, commit the .tres files.

const WIPE: Dictionary = {"cell": 20.0, "radius": 60.0, "threshold": 0.9}


func _init() -> void:
	var scenes: Array[SceneDef] = [
		_map(),
		_room("living_room", [_wipe(Rect2(300, 760, 1300, 320), 1), _toys_living_room()]),
		_room("kitchen", [_dishes(), _wipe(Rect2(200, 800, 1500, 280), 2)]),
		_room("bathroom", [_wipe(Rect2(180, 540, 760, 460), 2), _wipe(Rect2(1520, 80, 360, 340), 1)]),
		_room("bedroom", [_tidy_clothes(), _wipe(Rect2(300, 760, 1300, 320), 1)]),
		_room("garden", [_sweep_piles()]),
	]
	for scene: SceneDef in scenes:
		var errors: PackedStringArray = scene.validate()
		if not errors.is_empty():
			push_error("%s: %s" % [scene.id, errors])
			quit(1)
			return
		var status: int = ResourceSaver.save(scene, "res://data/scenes/%s.tres" % scene.id)
		if status != OK:
			quit(status)
			return
	quit(0)


func _reaction(kind: String, value: String) -> Reaction:
	var reaction: Reaction = Reaction.new()
	reaction.kind = kind
	reaction.value = value
	return reaction


func _step(template: String, params: Dictionary, hit: Array[Reaction], miss: Array[Reaction]) -> StepDef:
	var step: StepDef = StepDef.new()
	step.template = template
	step.params = params
	step.on_hit = hit
	step.on_miss = miss
	return step


func _room(id: String, steps: Array[StepDef]) -> SceneDef:
	var scene: SceneDef = SceneDef.new()
	scene.id = id
	scene.background = "backgrounds/" + id
	scene.music = "music/main_theme"
	scene.next = "house_map"
	scene.steps = steps
	return scene


func _wipe(layer: Rect2, levels: int) -> StepDef:
	var params: Dictionary = WIPE.duplicate()
	params["tool"] = "sponge"
	params["layer_rect"] = layer
	params["levels"] = levels
	var hit: Array[Reaction] = [_reaction("sfx", "bubble"), _reaction("pose", "laugh")]
	return _step("t23_erase", params, hit, [] as Array[Reaction])


func _carry(items: Array, homes: Dictionary, target: Rect2) -> StepDef:
	var params: Dictionary = {"items": items, "homes": homes, "target_rect": target}
	var hit: Array[Reaction] = [_reaction("sfx", "success"), _reaction("pose", "jump"), _reaction("fx", "sparkle")]
	var miss: Array[Reaction] = [_reaction("sfx", "soft_miss"), _reaction("pose", "idle")]
	return _step("t20_drag_snap", params, hit, miss)


func _toys_living_room() -> StepDef:
	var homes: Dictionary = {"ball": Vector2(980, 860), "plush": Vector2(1180, 940), "toy_duck": Vector2(800, 940)}
	return _carry(["ball", "plush", "toy_duck"], homes, Rect2(430, 300, 320, 500))


func _dishes() -> StepDef:
	var homes: Dictionary = {"bowl": Vector2(560, 880), "cupcake": Vector2(860, 940), "juice": Vector2(1120, 900)}
	return _carry(["bowl", "cupcake", "juice"], homes, Rect2(1220, 540, 360, 300))


func _touch_each(targets: Array, positions: Dictionary, art: Dictionary) -> StepDef:
	var params: Dictionary = {"targets": targets, "positions": positions, "art": art}
	var hit: Array[Reaction] = [_reaction("sfx", "select"), _reaction("pose", "jump"), _reaction("fx", "sparkle")]
	return _step("t21_touch_each", params, hit, [] as Array[Reaction])


func _tidy_clothes() -> StepDef:
	var positions: Dictionary = {
		"hat": Vector2(700, 880), "scarf": Vector2(1000, 940), "bow": Vector2(1300, 900), "plush": Vector2(900, 800)
	}
	var art: Dictionary = {"hat": "items/hat", "scarf": "items/scarf", "bow": "items/bow", "plush": "items/plush"}
	return _touch_each(["hat", "scarf", "bow", "plush"], positions, art)


func _sweep_piles() -> StepDef:
	var positions: Dictionary = {
		"pile_1": Vector2(500, 820),
		"pile_2": Vector2(900, 940),
		"pile_3": Vector2(1350, 840),
		"pile_4": Vector2(1650, 940)
	}
	var art: Dictionary = {}
	for id: String in positions:
		art[id] = "effects/crumbs"
	return _touch_each(["pile_1", "pile_2", "pile_3", "pile_4"], positions, art)


func _map() -> SceneDef:
	var scene: SceneDef = SceneDef.new()
	scene.id = "house_map"
	scene.background = "backgrounds/house"
	scene.music = "music/main_theme"
	var ids: Array[String] = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]
	var origins: Array[Vector2] = [
		Vector2(190, 200), Vector2(730, 200), Vector2(1270, 200), Vector2(460, 600), Vector2(1000, 600)
	]
	var rooms: Array = []
	for index: int in ids.size():
		rooms.append(
			{"id": ids[index], "rect": Rect2(origins[index], Vector2(460, 320)), "art": "backgrounds/" + ids[index]}
		)
	scene.steps = [_step("t25_map", {"rooms": rooms}, [_reaction("sfx", "tap")], [] as Array[Reaction])]
	return scene
