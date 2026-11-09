class_name Player
extends Control
## The one player (ADR-001). It builds a view for each step of a SceneDef and lets the
## ScenePlayer Fsm decide the order. There is no per-scene code here.

signal left(target: String)
## The scene could not run (missing, invalid or a template with no view yet). Boot recovers.
signal failed(scene: String)

const SCENE_DIR: String = "res://data/scenes/"
const OUTRO_POSE: String = "sparkle"
const STAGE_SIZE: Vector2 = Vector2(1920, 1080)
const HIT_GROUP: String = "hit_target"

## A short celebration after a step is complete. It never ends a step, which is already done.
var beat_sec: float = 0.6
## Content lives on a 1920x1080 stage centered in any screen; only the background fills it.
var stage: Control = Control.new()
## Tests and tools can hand a scene in instead of loading it from data/scenes.
var def_override: SceneDef = null
## Shared by the whole session. Null means no progress is kept.
var house: HouseState = null
var home_button: TextureButton = null
var outro_button: TextureButton = null
var meter: RoomMeter = RoomMeter.new()
var scene_id: String = "living_room"
var scene_player: ScenePlayer = ScenePlayer.new()
var hint: HintTimer = HintTimer.new(5.0)

var _view: Control = null
var _run: int = 0
var _sink: GameSink = GameSink.new()
var _quiqui: TextureRect = TextureRect.new()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var def: SceneDef = def_override
	var path: String = "%s%s.tres" % [SCENE_DIR, scene_id]
	if def == null and ResourceLoader.exists(path):
		def = load(path) as SceneDef
	if def == null or not scene_player.load_scene(def) or not _all_supported(def):
		push_error("scene %s is missing, invalid or unsupported: %s" % [scene_id, scene_player.errors])
		Log.error("scene_invalid", {"scene": scene_id, "errors": scene_player.errors.size()})
		failed.emit.call_deferred(scene_id)
		return
	Log.info("scene_loaded", {"scene": scene_id, "steps": def.steps.size()})
	_build_chrome(def)
	scene_player.step_started.connect(_on_step_started)
	scene_player.fsm.transitioned.connect(_on_transitioned)
	scene_player.exited.connect(_on_exited)
	_begin()


func _process(delta: float) -> void:
	if scene_player.state() == ScenePlayer.STEP:
		hint.tick(delta)


## The template of the running step, or null between steps.
func template() -> StepTemplate:
	if _view == null:
		return null
	return _view.get("template") as StepTemplate


func play_again() -> void:
	_run += 1
	Log.info("play_again", {"scene": scene_id})
	_clear_view()
	if outro_button != null:
		outro_button.visible = false
	scene_player.restart()
	hint.start()
	_begin()


func _begin() -> void:
	_sink.play_pose(scene_player.scene.quiqui_pose)
	scene_player.advance()
	scene_player.advance()


func _build_chrome(def: SceneDef) -> void:
	_build_background(def)
	_quiqui.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_quiqui.size = Vector2(380, 380)
	_quiqui.position = Vector2(1480, 500)
	_quiqui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(_quiqui)
	_sink.quiqui = _quiqui
	_sink.host = stage
	_sink.audio_host = audio_host()
	home_button = _button("ui/home_button", Vector2(40, 40), go_home)
	stage.add_child(home_button)
	_build_meter(def)
	hint.hint_shown.connect(func() -> void: _set_hint(true))
	hint.hint_hidden.connect(func() -> void: _set_hint(false))


func _build_background(def: SceneDef) -> void:
	var background: TextureRect = TextureRect.new()
	background.texture = Assets.texture(def.background)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_to_group("background")
	add_child(background)
	stage.size = STAGE_SIZE
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)
	resized.connect(_center_stage)
	_center_stage()


func _all_supported(def: SceneDef) -> bool:
	for step: StepDef in def.steps:
		if not ViewFactory.supports(step.template):
			return false
	return true


## Sounds go to the tree root, so a tap that changes scene is still heard.
func audio_host() -> Node:
	return get_tree().root


func _is_map(def: SceneDef) -> bool:
	return def.steps.size() == 1 and def.steps[0].template == "t25_map"


func _build_meter(def: SceneDef) -> void:
	meter.configure(def.steps.size())
	meter.position = Vector2((STAGE_SIZE.x - meter.size.x) * 0.5, 40)
	stage.add_child(meter)
	var on_map: bool = _is_map(def)
	meter.visible = not on_map
	home_button.visible = not on_map
	_quiqui.visible = not on_map


func _center_stage() -> void:
	stage.position = (size - STAGE_SIZE) * 0.5


func go_home() -> void:
	scene_player.go_home()


func _button(key: String, at: Vector2, action: Callable) -> TextureButton:
	var button: TextureButton = TextureButton.new()
	button.texture_normal = Assets.texture(key)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = Vector2(170, 170)
	button.size = Vector2(170, 170)
	button.position = at
	button.pressed.connect(action)
	button.add_to_group(HIT_GROUP)
	return button


func _on_step_started(index: int, step: StepDef) -> void:
	Log.info("step_started", {"scene": scene_id, "index": index, "template": step.template})
	_clear_view()
	hint.notify_input()
	meter.fill(index)
	_view = ViewFactory.make(step, _clean_rooms())
	stage.add_child(_view)
	stage.move_child(_view, 0)
	var template_now: StepTemplate = template()
	template_now.hit.connect(func() -> void: ReactionRunner.run(step.on_hit, _sink))
	template_now.miss.connect(func() -> void: ReactionRunner.run(step.on_miss, _sink))
	template_now.completed.connect(_on_step_completed)
	if template_now is MapTemplate:
		(template_now as MapTemplate).room_chosen.connect(scene_player.leave_to)
	_view.connect("touched", hint.notify_input)


func _clean_rooms() -> Array[String]:
	if house == null:
		return [] as Array[String]
	return house.clean_ids()


## The outro button: on to the next scene, usually the map.
func continue_to_next() -> void:
	scene_player.advance()


func _on_step_completed() -> void:
	var index: int = scene_player.step_index
	if beat_sec <= 0.0:
		_finish_step(index, _run)
		return
	var tween: Tween = create_tween()
	tween.tween_interval(beat_sec)
	tween.tween_callback(_finish_step.bind(index, _run))


## Ends a completed step. A beat that was overtaken (Home, play again) does nothing.
func _finish_step(index: int, run: int) -> void:
	if run != _run or scene_player.state() != ScenePlayer.STEP or scene_player.step_index != index:
		return
	Log.info("step_completed", {"scene": scene_id, "index": index})
	scene_player.step_finished()
	scene_player.advance()


func _on_exited(target: String) -> void:
	_run += 1
	Log.info("scene_left", {"scene": scene_id, "next": target})
	left.emit(target)


func _on_transitioned(_from: String, to_state: String) -> void:
	if to_state == ScenePlayer.OUTRO:
		_show_outro()


func _show_outro() -> void:
	_clear_view()
	hint.stop()
	meter.fill(scene_player.scene.steps.size())
	if house != null:
		house.mark_clean(scene_id)
	_sink.play_pose(OUTRO_POSE)
	_sink.play_sfx("success")
	_sink.play_fx("sparkle")
	if outro_button == null:
		outro_button = _button("ui/play_button", Vector2(840, 420), continue_to_next)
		outro_button.size = Vector2(240, 240)
		stage.add_child(outro_button)
	outro_button.visible = true


func _set_hint(on: bool) -> void:
	if _view != null:
		_view.call("set_hint", on)


func _clear_view() -> void:
	if _view != null:
		_view.queue_free()
		_view = null
