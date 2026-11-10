class_name TitleView
extends Control
## The view of t0_title: a big play button and, in a corner, a lock that opens the parent area after a long hold.

signal touched

const LOCK_SIZE: Vector2 = Vector2(140, 140)

var template: TitleTemplate = TitleTemplate.new()
var gate: ParentGate = ParentGate.new()
var play_button: TextureButton = TextureButton.new()
var lock_button: TextureRect = TextureRect.new()
var panel: ParentPanel = ParentPanel.new()

var _ring: Control = Control.new()
var _pulse: Tween = null


func configure(_params: Dictionary) -> void:
	template.setup({})
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_play()
	_build_lock()
	add_child(panel)
	panel.reset_confirmed.connect(template.request_reset)
	panel.closed.connect(gate.close)
	gate.opened.connect(panel.open)


func _process(delta: float) -> void:
	gate.tick(delta)
	_ring.queue_redraw()


func set_hint(on: bool) -> void:
	if _pulse != null:
		_pulse.kill()
	play_button.scale = Vector2.ONE
	if on:
		_pulse = play_button.create_tween().set_loops()
		_pulse.tween_property(play_button, "scale", Vector2(1.12, 1.12), 0.5)
		_pulse.tween_property(play_button, "scale", Vector2.ONE, 0.5)


func _build_play() -> void:
	play_button.texture_normal = Assets.texture("ui/play_button")
	play_button.ignore_texture_size = true
	play_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	play_button.size = Vector2(320, 320)
	play_button.position = Vector2(800, 460)
	play_button.pivot_offset = play_button.size * 0.5
	play_button.add_to_group("hit_target")
	play_button.pressed.connect(_on_play)
	add_child(play_button)


func _on_play() -> void:
	touched.emit()
	template.play()


func _build_lock() -> void:
	lock_button.texture = Assets.texture("ui/lock")
	lock_button.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lock_button.size = LOCK_SIZE
	lock_button.position = Vector2(1740, 900)
	lock_button.mouse_filter = Control.MOUSE_FILTER_STOP
	lock_button.add_to_group("hit_target")
	lock_button.gui_input.connect(_on_lock_input)
	add_child(lock_button)
	_ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.draw.connect(_draw_ring)
	lock_button.add_child(_ring)


func _on_lock_input(event: InputEvent) -> void:
	if StepTemplate.is_echo(event) or not event is InputEventScreenTouch:
		return
	touched.emit()
	if (event as InputEventScreenTouch).pressed:
		gate.press()
	else:
		gate.release()


## The ring fills while the lock is held. A tap shows almost nothing.
func _draw_ring() -> void:
	if gate.progress() > 0.0:
		var center: Vector2 = LOCK_SIZE * 0.5
		_ring.draw_arc(center, 66.0, -PI / 2.0, -PI / 2.0 + TAU * gate.progress(), 48, Color(0.48, 0.29, 0.08), 10.0)
