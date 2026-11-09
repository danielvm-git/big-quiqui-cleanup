class_name Player
extends Control
## The one player (ADR-001). It builds a view for each step of a SceneDef and lets the
## ScenePlayer Fsm decide the order. There is no per-scene code here.

signal left(target: String)

const SCENE_DIR: String = "res://data/scenes/"
const OUTRO_POSE: String = "sparkle"

var scene_id: String = "living_room"
var scene_player: ScenePlayer = ScenePlayer.new()
var hint: HintTimer = HintTimer.new(5.0)

var _view: Control = null
var _sink: GameSink = GameSink.new()
var _quiqui: TextureRect = TextureRect.new()
var _outro: Control = null


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var def: SceneDef = load("%s%s.tres" % [SCENE_DIR, scene_id]) as SceneDef
	if not scene_player.load_scene(def):
		push_error("scene %s is invalid: %s" % [scene_id, scene_player.errors])
		return
	_build_chrome(def)
	scene_player.step_started.connect(_on_step_started)
	scene_player.fsm.transitioned.connect(_on_transitioned)
	scene_player.exited.connect(func(target: String) -> void: left.emit(target))
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
	_clear_view()
	if _outro != null:
		_outro.visible = false
	scene_player.restart()
	_begin()


func _begin() -> void:
	_sink.play_pose(scene_player.scene.quiqui_pose)
	scene_player.advance()
	scene_player.advance()


func _build_chrome(def: SceneDef) -> void:
	var background: TextureRect = TextureRect.new()
	background.texture = Assets.texture(def.background)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_quiqui.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_quiqui.size = Vector2(380, 380)
	_quiqui.position = Vector2(1480, 500)
	_quiqui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_quiqui)
	_sink.quiqui = _quiqui
	_sink.host = self
	add_child(_button("ui/home_button", Vector2(40, 40), go_home))
	_sink.play_music(def.music)
	hint.hint_shown.connect(func() -> void: _set_hint(true))
	hint.hint_hidden.connect(func() -> void: _set_hint(false))


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
	return button


func _on_step_started(_index: int, step: StepDef) -> void:
	_clear_view()
	hint.notify_input()
	_view = _make_view(step)
	add_child(_view)
	move_child(_view, 1)
	var template_now: StepTemplate = template()
	template_now.hit.connect(func() -> void: ReactionRunner.run(step.on_hit, _sink))
	template_now.miss.connect(func() -> void: ReactionRunner.run(step.on_miss, _sink))
	template_now.completed.connect(_on_step_completed)
	_view.connect("touched", hint.notify_input)


func _make_view(step: StepDef) -> Control:
	var view: Control = DirtView.new() if step.template == "t23_erase" else ToyView.new()
	view.call("configure", step.params)
	return view


func _on_step_completed() -> void:
	scene_player.step_finished()
	scene_player.advance()


func _on_transitioned(_from: String, to_state: String) -> void:
	if to_state == ScenePlayer.OUTRO:
		_show_outro()


func _show_outro() -> void:
	_clear_view()
	hint.stop()
	_sink.play_pose(OUTRO_POSE)
	_sink.play_sfx("success")
	_sink.play_fx("sparkle")
	if _outro == null:
		_outro = _button("ui/play_button", Vector2(875, 450), play_again)
		_outro.size = Vector2(240, 240)
		add_child(_outro)
	_outro.visible = true


func _set_hint(on: bool) -> void:
	if _view != null:
		_view.call("set_hint", on)


func _clear_view() -> void:
	if _view != null:
		_view.queue_free()
		_view = null
