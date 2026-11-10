# story: e02s06
extends GutTest
## Review findings for e02: sound that outlives the scene, beat races, stuck pulses, bad scenes.


func _step(template: String, params: Dictionary) -> StepDef:
	var step: StepDef = StepDef.new()
	step.template = template
	step.params = params
	return step


func _touch_def() -> SceneDef:
	var def: SceneDef = SceneDef.new()
	def.id = "kitchen"
	def.background = "backgrounds/living_room"
	def.next = "house_map"
	var params: Dictionary = {"targets": ["a"], "positions": {"a": Vector2(400, 400)}, "art": {"a": "items/ball"}}
	def.steps = [_step("t21_touch_each", params), _step("t21_touch_each", params)] as Array[StepDef]
	return def


func _open(def: SceneDef, beat: float) -> Player:
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.beat_sec = beat
	player.def_override = def
	player.scene_id = def.id
	add_child_autofree(player)
	return player


func test_a_sound_plays_on_a_node_that_outlives_the_scene() -> void:
	var sink: GameSink = GameSink.new()
	var scene_host: Control = Control.new()
	var audio_host: Node = Node.new()
	add_child_autofree(scene_host)
	add_child_autofree(audio_host)
	sink.host = scene_host
	sink.audio_host = audio_host
	sink.play_sfx("tap")
	assert_eq(audio_host.get_child_count(), 1)
	assert_eq(scene_host.get_child_count(), 0)


func test_the_player_sends_its_sounds_to_the_tree_root() -> void:
	var player: Player = _open(_touch_def(), 0.0)
	assert_eq(player.audio_host(), get_tree().root)


func test_home_during_the_beat_frees_the_player_without_errors() -> void:
	var holder: Node = Node.new()
	add_child_autofree(holder)
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.beat_sec = 0.2
	player.def_override = _touch_def()
	player.scene_id = "kitchen"
	holder.add_child(player)
	StepSolver.solve(player.template(), player.scene_player.current_step().params)
	player.go_home()
	player.queue_free()
	await wait_seconds(0.4)
	assert_false(is_instance_valid(player))


func test_play_again_inside_the_beat_is_not_ended_by_the_old_beat() -> void:
	var player: Player = _open(_touch_def(), 0.2)
	StepSolver.solve(player.template(), player.scene_player.current_step().params)
	player.play_again()
	await wait_seconds(0.4)
	assert_eq(player.scene_player.step_index, 0)
	assert_eq(player.scene_player.state(), ScenePlayer.STEP)


func test_a_hint_pulse_leaves_the_target_at_normal_size() -> void:
	var player: Player = _open(_touch_def(), 0.0)
	var view: TouchView = player.stage.get_child(0) as TouchView
	view.set_hint(true)
	await wait_seconds(0.2)
	view.set_hint(false)
	assert_eq((view.get_node("a") as Control).scale, Vector2.ONE)


func test_the_outro_button_is_centered_on_the_stage() -> void:
	var player: Player = _open(_touch_def(), 0.0)
	StepSolver.solve(player.template(), player.scene_player.current_step().params)
	StepSolver.solve(player.template(), player.scene_player.current_step().params)
	var center: Vector2 = player.outro_button.position + player.outro_button.size * 0.5
	assert_eq(center, Vector2(960, 540))


func test_a_scene_with_an_unsupported_template_reports_failed() -> void:
	ViewFactory.supported.erase("t0_title")
	var def: SceneDef = SceneDef.new()
	def.id = "title"
	def.background = "backgrounds/living_room"
	def.steps = [_step("t0_title", {})] as Array[StepDef]
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.def_override = def
	player.scene_id = "title"
	watch_signals(player)
	add_child_autofree(player)
	await get_tree().process_frame
	ViewFactory.supported.append("t0_title")
	assert_signal_emitted(player, "failed")
	assert_push_error("unsupported")


func test_a_missing_scene_reports_failed() -> void:
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.scene_id = "attic"
	watch_signals(player)
	add_child_autofree(player)
	await get_tree().process_frame
	assert_signal_emitted(player, "failed")
	assert_push_error("unsupported")
