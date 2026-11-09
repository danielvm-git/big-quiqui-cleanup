# story: e02s06
extends GutTest
## Map, rooms, Home and the outro button connect through scene ids. The player never
## knows which room it runs: it reads a SceneDef.

const ROOMS: Array[String] = ["kitchen", "garden"]


func _step(template: String, params: Dictionary) -> StepDef:
	var step: StepDef = StepDef.new()
	step.template = template
	step.params = params
	return step


func _touch_step() -> StepDef:
	return _step(
		"t21_touch_each",
		{
			"targets": ["a", "b"],
			"positions": {"a": Vector2(400, 400), "b": Vector2(800, 400)},
			"art": {"a": "items/ball", "b": "items/plush"},
		},
	)


func _map_def() -> SceneDef:
	var def: SceneDef = SceneDef.new()
	def.id = "house_map"
	def.background = "backgrounds/living_room"
	var rooms: Array = []
	for index: int in ROOMS.size():
		rooms.append(
			{"id": ROOMS[index], "rect": Rect2(200 + index * 600, 300, 500, 350), "art": "backgrounds/living_room"}
		)
	def.steps = [_step("t25_map", {"rooms": rooms})] as Array[StepDef]
	return def


func _room_def(steps: int = 1) -> SceneDef:
	var def: SceneDef = SceneDef.new()
	def.id = "kitchen"
	def.background = "backgrounds/living_room"
	def.next = "house_map"
	var list: Array[StepDef] = []
	for index: int in steps:
		list.append(_touch_step())
	def.steps = list
	return def


func _open(def: SceneDef, house: HouseState = null) -> Player:
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.beat_sec = 0.0
	player.def_override = def
	player.scene_id = def.id
	player.house = house if house != null else HouseState.new(ROOMS)
	add_child_autofree(player)
	return player


func _finish_step(player: Player) -> void:
	for id: String in (player.template() as TouchEachTemplate).remaining():
		(player.template() as TouchEachTemplate).touch(id)


func test_choosing_a_room_on_the_map_leaves_to_it() -> void:
	var player: Player = _open(_map_def())
	watch_signals(player)
	(player.template() as MapTemplate).choose_room("garden")
	assert_signal_emitted_with_parameters(player, "left", ["garden"])


func test_the_map_shows_the_rooms_the_house_knows_are_clean() -> void:
	var house: HouseState = HouseState.new(ROOMS)
	house.mark_clean("kitchen")
	var player: Player = _open(_map_def(), house)
	var template: MapTemplate = player.template() as MapTemplate
	assert_true(template.is_clean("kitchen"))
	assert_false(template.is_clean("garden"))


func test_the_map_has_no_home_button() -> void:
	assert_false(_open(_map_def()).home_button.visible)


func test_a_room_has_a_home_button() -> void:
	assert_true(_open(_room_def()).home_button.visible)


func test_finishing_a_room_marks_it_clean() -> void:
	var house: HouseState = HouseState.new(ROOMS)
	var player: Player = _open(_room_def(), house)
	_finish_step(player)
	assert_eq(player.scene_player.state(), ScenePlayer.OUTRO)
	assert_true(house.is_clean("kitchen"))


func test_the_outro_button_continues_to_the_map() -> void:
	var player: Player = _open(_room_def())
	_finish_step(player)
	watch_signals(player)
	player.outro_button.pressed.emit()
	assert_signal_emitted_with_parameters(player, "left", ["house_map"])


func test_home_in_a_room_leaves_with_no_target_and_keeps_the_room_dirty() -> void:
	var house: HouseState = HouseState.new(ROOMS)
	var player: Player = _open(_room_def(), house)
	watch_signals(player)
	player.go_home()
	assert_signal_emitted_with_parameters(player, "left", [""])
	assert_false(house.is_clean("kitchen"))


func test_the_meter_has_a_dot_per_step_and_fills_as_steps_finish() -> void:
	var player: Player = _open(_room_def(2))
	assert_eq(player.meter.get_child_count(), 2)
	assert_eq(player.meter.filled(), 0)
	_finish_step(player)
	assert_eq(player.meter.filled(), 1)
	_finish_step(player)
	assert_eq(player.meter.filled(), 2)


func test_the_map_has_no_meter() -> void:
	assert_false(_open(_map_def()).meter.visible)


func test_house_state_reads_its_rooms_from_the_map() -> void:
	var house: HouseState = HouseState.from_map(_map_def())
	assert_eq(house.rooms, ROOMS)
