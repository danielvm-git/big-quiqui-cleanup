# story: e01s07
extends GutTest
## A child cleans the living room and asks to play again, driven through the templates
## (headless viewports do not dispatch GUI input; see TouchSim).


func _player() -> Player:
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.beat_sec = 0.0
	add_child_autofree(player)
	return player


func _wipe(erase: EraseTemplate) -> void:
	var rect: Rect2 = Rect2(300, 760, 1300, 320)
	var y: float = rect.position.y
	while y <= rect.end.y and not erase.is_done():
		erase.rub_begin(Vector2(rect.position.x, y))
		erase.rub_to(Vector2(rect.end.x, y))
		erase.rub_end()
		y += 40.0


func _tidy(drag: DragSnapTemplate) -> void:
	for id: String in drag.remaining():
		drag.pick(id)
		drag.drop(Vector2(590, 550))


func test_starts_on_the_first_step_with_the_wipe() -> void:
	var player: Player = _player()
	assert_eq(player.scene_player.state(), ScenePlayer.STEP)
	assert_true(player.template() is EraseTemplate)


func test_cleaning_the_room_reaches_the_outro() -> void:
	var player: Player = _player()
	_wipe(player.template() as EraseTemplate)
	assert_true(player.template() is DragSnapTemplate)
	_tidy(player.template() as DragSnapTemplate)
	assert_eq(player.scene_player.state(), ScenePlayer.OUTRO)


func test_a_missed_toy_comes_back_and_the_step_stays_open() -> void:
	var player: Player = _player()
	_wipe(player.template() as EraseTemplate)
	var drag: DragSnapTemplate = player.template() as DragSnapTemplate
	drag.pick("ball")
	drag.drop(Vector2(10, 10))
	assert_true(drag.remaining().has("ball"))
	assert_eq(player.scene_player.state(), ScenePlayer.STEP)


func test_play_again_restarts_at_the_first_step() -> void:
	var player: Player = _player()
	_wipe(player.template() as EraseTemplate)
	_tidy(player.template() as DragSnapTemplate)
	player.play_again()
	assert_eq(player.scene_player.state(), ScenePlayer.STEP)
	assert_eq(player.scene_player.step_index, 0)
	assert_true(player.template() is EraseTemplate)
	assert_eq((player.template() as EraseTemplate).coverage(), 0.0)


func test_home_leaves_from_any_step() -> void:
	var player: Player = _player()
	watch_signals(player)
	player.go_home()
	assert_signal_emitted(player, "left")


func test_the_hint_comes_back_after_play_again() -> void:
	var player: Player = _player()
	_wipe(player.template() as EraseTemplate)
	_tidy(player.template() as DragSnapTemplate)
	player.play_again()
	watch_signals(player.hint)
	player.hint.tick(60.0)
	assert_signal_emitted(player.hint, "hint_shown")


func test_the_beat_lets_the_last_answer_show_before_the_step_ends() -> void:
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.beat_sec = 0.2
	add_child_autofree(player)
	_wipe(player.template() as EraseTemplate)
	assert_eq(player.scene_player.state(), ScenePlayer.STEP)
	assert_eq(player.scene_player.step_index, 0)
	await wait_seconds(0.4)
	assert_eq(player.scene_player.step_index, 1)


func test_home_during_the_beat_is_not_overridden() -> void:
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.beat_sec = 0.2
	add_child_autofree(player)
	_wipe(player.template() as EraseTemplate)
	player.go_home()
	await wait_seconds(0.4)
	assert_eq(player.scene_player.state(), ScenePlayer.EXIT)
