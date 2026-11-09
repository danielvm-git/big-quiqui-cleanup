class_name ToyView
extends Control
## The view of t20_drag_snap: toys on the floor, carried to the target. A miss slides back.

signal touched

const TOY_SIZE: Vector2 = Vector2(170, 170)

var template: DragSnapTemplate = DragSnapTemplate.new()

var _homes: Dictionary = {}
var _target: Rect2 = Rect2()
var _toys: Dictionary = {}
var _pulse: Tween = null
var _pulsed: Control = null
var _slide: Dictionary = {}


func configure(params: Dictionary) -> void:
	template.setup(params)
	_homes = params["homes"] as Dictionary
	_target = params["target_rect"] as Rect2
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for id: String in template.remaining():
		_add_toy(id)


func set_hint(on: bool) -> void:
	_stop_hint()
	var left: Array[String] = template.remaining()
	if not on or left.is_empty():
		return
	var toy: TextureRect = _toys[left[0]] as TextureRect
	toy.pivot_offset = TOY_SIZE * 0.5
	_pulsed = toy
	_pulse = toy.create_tween().set_loops()
	_pulse.tween_property(toy, "scale", Vector2(1.25, 1.25), 0.4)
	_pulse.tween_property(toy, "scale", Vector2.ONE, 0.4)


func _add_toy(id: String) -> void:
	var toy: TextureRect = TextureRect.new()
	toy.texture = Assets.texture("items/" + id)
	toy.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	toy.size = TOY_SIZE
	toy.position = (_homes[id] as Vector2) - TOY_SIZE * 0.5
	toy.mouse_filter = Control.MOUSE_FILTER_STOP
	toy.add_to_group("hit_target")
	toy.gui_input.connect(_on_toy_input.bind(id, toy))
	add_child(toy)
	_toys[id] = toy


func _on_toy_input(event: InputEvent, id: String, toy: TextureRect) -> void:
	if StepTemplate.is_echo(event):
		return
	touched.emit()
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		_on_touch(touch, id, toy, toy.position + touch.position)
	elif event is InputEventScreenDrag and template.held == id:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		toy.position = toy.position + drag.position - TOY_SIZE * 0.5


func _on_touch(event: InputEventScreenTouch, id: String, toy: TextureRect, point: Vector2) -> void:
	if event.pressed:
		if template.pick(id):
			if _slide.has(id):
				(_slide[id] as Tween).kill()
			_stop_hint()
		return
	if template.held != id:
		return
	if template.drop(point):
		_deliver(toy)
	else:
		_return_home(id, toy)


func _deliver(toy: TextureRect) -> void:
	toy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween: Tween = toy.create_tween().set_parallel(true)
	tween.tween_property(toy, "position", _target.get_center() - TOY_SIZE * 0.5, 0.2)
	tween.tween_property(toy, "modulate:a", 0.0, 0.3)


func _return_home(id: String, toy: TextureRect) -> void:
	var home: Vector2 = (_homes[id] as Vector2) - TOY_SIZE * 0.5
	_slide[id] = toy.create_tween()
	(_slide[id] as Tween).tween_property(toy, "position", home, 0.25).set_trans(Tween.TRANS_BACK)


func _stop_hint() -> void:
	if _pulse != null:
		_pulse.kill()
	if _pulsed != null and is_instance_valid(_pulsed):
		_pulsed.scale = Vector2.ONE
	_pulsed = null
