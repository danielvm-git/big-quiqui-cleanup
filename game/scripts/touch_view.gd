class_name TouchView
extends Control
## The view of t21_touch_each: pictures to tap. A touched one pops and goes away.

signal touched

const TARGET_SIZE: Vector2 = Vector2(180, 180)

var template: TouchEachTemplate = TouchEachTemplate.new()

var _pulse: Tween = null


func configure(params: Dictionary) -> void:
	template.setup(params)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var positions: Dictionary = params["positions"] as Dictionary
	var art: Dictionary = params["art"] as Dictionary
	for id: String in template.remaining():
		_add_target(id, positions[id] as Vector2, str(art[id]))


func set_hint(on: bool) -> void:
	if _pulse != null:
		_pulse.kill()
	var left: Array[String] = template.remaining()
	if not on or left.is_empty():
		return
	var target: Control = get_node(left[0]) as Control
	target.pivot_offset = TARGET_SIZE * 0.5
	_pulse = target.create_tween().set_loops()
	_pulse.tween_property(target, "scale", Vector2(1.25, 1.25), 0.4)
	_pulse.tween_property(target, "scale", Vector2.ONE, 0.4)


func _add_target(id: String, center: Vector2, art_key: String) -> void:
	var target: TextureRect = TextureRect.new()
	target.name = id
	target.texture = Assets.texture(art_key)
	target.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	target.size = TARGET_SIZE
	target.position = center - TARGET_SIZE * 0.5
	target.pivot_offset = TARGET_SIZE * 0.5
	target.mouse_filter = Control.MOUSE_FILTER_STOP
	target.add_to_group("hit_target")
	target.gui_input.connect(_on_target_input.bind(id, target))
	add_child(target)


func _on_target_input(event: InputEvent, id: String, target: TextureRect) -> void:
	if StepTemplate.is_echo(event):
		return
	touched.emit()
	if not event is InputEventScreenTouch or not (event as InputEventScreenTouch).pressed:
		return
	target.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _pulse != null:
		_pulse.kill()
	target.scale = Vector2.ONE
	if template.touch(id):
		_pop(target)


func _pop(target: TextureRect) -> void:
	var tween: Tween = target.create_tween().set_parallel(true)
	tween.tween_property(target, "scale", Vector2(1.5, 1.5), 0.25)
	tween.tween_property(target, "modulate:a", 0.0, 0.3)
