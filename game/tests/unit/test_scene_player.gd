# story: e01s03
extends GutTest
## The scene player is an Fsm table: LOAD, INTRO, STEP, STEP_DONE, OUTRO, EXIT.
## Home leaves from every state with no penalty, and a finished scene can restart.


func _scene(step_count: int) -> SceneDef:
	var scene: SceneDef = SceneDef.new()
	scene.id = "living_room"
	scene.next = "hall"
	var steps: Array[StepDef] = []
	for index: int in step_count:
		var step: StepDef = StepDef.new()
		step.template = "t23_erase"
		steps.append(step)
	scene.steps = steps
	return scene


func _player(step_count: int = 2) -> ScenePlayer:
	var player: ScenePlayer = ScenePlayer.new()
	assert_true(player.load_scene(_scene(step_count)))
	return player


func test_starts_in_load() -> void:
	assert_eq(_player().state(), ScenePlayer.LOAD)


func test_invalid_scene_is_refused() -> void:
	var player: ScenePlayer = ScenePlayer.new()
	assert_false(player.load_scene(SceneDef.new()))
	assert_gt(player.errors.size(), 0)


func test_walks_every_state_in_order() -> void:
	var player: ScenePlayer = _player(1)
	var seen: Array[String] = [player.state()]
	while player.state() != ScenePlayer.EXIT:
		player.advance()
		seen.append(player.state())
		if player.state() == ScenePlayer.STEP:
			player.step_finished()
			seen.append(player.state())
	assert_eq(
		seen,
		["LOAD", "INTRO", "STEP", "STEP_DONE", "OUTRO", "EXIT"] as Array[String],
	)


func test_second_step_starts_after_the_first_is_done() -> void:
	var player: ScenePlayer = _player(2)
	player.advance()
	player.advance()
	assert_eq(player.step_index, 0)
	player.step_finished()
	player.advance()
	assert_eq(player.state(), ScenePlayer.STEP)
	assert_eq(player.step_index, 1)


func test_step_finished_outside_a_step_is_ignored() -> void:
	var player: ScenePlayer = _player()
	player.step_finished()
	assert_eq(player.state(), ScenePlayer.LOAD)


func test_home_leaves_from_every_state() -> void:
	for presses: int in 5:
		var player: ScenePlayer = _player(1)
		for index: int in presses:
			if player.state() == ScenePlayer.STEP:
				player.step_finished()
			player.advance()
		player.go_home()
		assert_eq(player.state(), ScenePlayer.EXIT, "after %d advances" % presses)


func test_exit_reports_the_next_scene_only_when_finished() -> void:
	var player: ScenePlayer = _player(1)
	player.go_home()
	assert_eq(player.exit_target, "")
	var done: ScenePlayer = _player(1)
	done.advance()
	done.advance()
	done.step_finished()
	done.advance()
	done.advance()
	assert_eq(done.exit_target, "hall")


func test_restart_goes_back_to_the_first_step() -> void:
	var player: ScenePlayer = _player(2)
	player.advance()
	player.advance()
	player.step_finished()
	player.go_home()
	player.restart()
	assert_eq(player.state(), ScenePlayer.LOAD)
	assert_eq(player.step_index, 0)


func test_no_state_has_a_dwell_limit() -> void:
	assert_eq(_player().fsm.max_dwell_sec.size(), 0)
