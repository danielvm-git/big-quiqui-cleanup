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


func configure(params: Dictionary) -> void:
	template.setup(params)
	_homes = params["homes"] as Dictionary
	_target = params["target_rect"] as Rect2
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for id: String in template.remaining():
		_add_toy(id)


func set_hint(on: bool) -> void:
	if _pulse != null:
		_pulse.kill()
	var left: Array[String] = template.remaining()
	if not on or left.is_empty():
		return
	var toy: TextureRect = _toys[left[0]] as TextureRect
	toy.pivot_offset = TOY_SIZE * 0.5
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
	toy.gui_input.connect(_on_toy_input.bind(id, toy))
	add_child(toy)
	_toys[id] = toy


func _on_toy_input(event: InputEvent, id: String, toy: TextureRect) -> void:
	touched.emit()
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		_on_touch(touch, id, toy, toy.get_global_transform() * touch.position)
	elif event is InputEventScreenDrag and template.held == id:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		toy.position = toy.get_global_transform() * drag.position - TOY_SIZE * 0.5


func _on_touch(event: InputEventScreenTouch, id: String, toy: TextureRect, point: Vector2) -> void:
	if event.pressed:
		if template.pick(id):
			_stop_pulse(toy)
		return
	if template.held != id:
		return
	if template.drop(point):
		_deliver(toy)
	else:
		_return_home(id, toy)


func _stop_pulse(toy: TextureRect) -> void:
	if _pulse != null:
		_pulse.kill()
	toy.scale = Vector2.ONE


func _deliver(toy: TextureRect) -> void:
	var tween: Tween = toy.create_tween().set_parallel(true)
	tween.tween_property(toy, "position", _target.get_center() - TOY_SIZE * 0.5, 0.2)
	tween.tween_property(toy, "modulate:a", 0.0, 0.3)


func _return_home(id: String, toy: TextureRect) -> void:
	var home: Vector2 = (_homes[id] as Vector2) - TOY_SIZE * 0.5
	toy.create_tween().tween_property(toy, "position", home, 0.25).set_trans(Tween.TRANS_BACK)
