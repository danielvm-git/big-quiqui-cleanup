# story: e02s02
extends GutTest
## TouchView shows each target and routes a tap to the template.


func _view() -> TouchView:
	var view: TouchView = TouchView.new()
	add_child_autofree(view)
	(
		view
		. configure(
			{
				"targets": ["lamp", "hat"],
				"positions": {"lamp": Vector2(300, 300), "hat": Vector2(700, 300)},
				"art": {"lamp": "items/ball", "hat": "items/plush"},
			},
		)
	)
	return view


func _tap(view: TouchView, id: String, pressed: bool = true) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.pressed = pressed
	event.position = Vector2(10, 10)
	(view.get_node(id) as Control).gui_input.emit(event)


func test_each_target_is_a_big_hit_target() -> void:
	var view: TouchView = _view()
	for id: String in ["lamp", "hat"]:
		var target: Control = view.get_node(id) as Control
		assert_true(target.is_in_group("hit_target"))
		assert_gte(target.size.x, 120.0)


func test_a_tap_touches_the_target_and_frees_the_touch() -> void:
	var view: TouchView = _view()
	watch_signals(view.template)
	_tap(view, "lamp")
	assert_signal_emitted(view.template, "hit")
	assert_eq((view.get_node("lamp") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_a_release_does_not_touch() -> void:
	var view: TouchView = _view()
	_tap(view, "lamp", false)
	assert_eq(view.template.remaining().size(), 2)


func test_a_synthesized_echo_does_not_count_as_input() -> void:
	var view: TouchView = _view()
	watch_signals(view)
	var echo: InputEventMouseButton = InputEventMouseButton.new()
	echo.device = -1
	echo.pressed = true
	(view.get_node("lamp") as Control).gui_input.emit(echo)
	assert_signal_not_emitted(view, "touched")
	_tap(view, "lamp")
	assert_signal_emitted(view, "touched")


func test_touching_all_completes() -> void:
	var view: TouchView = _view()
	_tap(view, "lamp")
	_tap(view, "hat")
	assert_true(view.template.is_done())
