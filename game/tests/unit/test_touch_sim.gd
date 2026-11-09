# story: e01s01
extends GutTest
## TouchSim emits the touch plus the synthesized mouse echo (device -1), so a handler
## that forgets the filter fails a test.


func _make_control() -> Control:
	var control: Control = Control.new()
	control.position = Vector2(100, 100)
	control.size = Vector2(200, 100)
	add_child_autofree(control)
	return control


func test_tap_has_touch_echo_and_release() -> void:
	var events: Array[InputEvent] = TouchSim.tap_events(_make_control())
	assert_eq(events.size(), 4)
	assert_true(events[0] is InputEventScreenTouch)
	assert_true(events[1] is InputEventMouseButton)
	assert_eq((events[1] as InputEventMouseButton).device, -1)


func test_tap_without_echo_is_two_touch_events() -> void:
	var events: Array[InputEvent] = TouchSim.tap_events(_make_control(), false)
	assert_eq(events.size(), 2)


func test_drag_ends_at_the_target() -> void:
	var control: Control = _make_control()
	var target: Vector2 = Vector2(500, 400)
	var events: Array[InputEvent] = TouchSim.drag_events(control, target, 4, false)
	var last: InputEventScreenTouch = events.back() as InputEventScreenTouch
	assert_false(last.pressed)
	assert_eq(last.position, target)
