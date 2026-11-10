# story: e03s03
extends GutTest
## RewardView lays the stars out on the stage and routes taps to the template.


func _view(count: int = 3) -> RewardView:
	var view: RewardView = RewardView.new()
	add_child_autofree(view)
	view.configure({"stars": count})
	return view


func _tap(view: RewardView, id: String, pressed: bool = true, device: int = 0) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.pressed = pressed
	event.position = Vector2(10, 10)
	(view.get_node(id) as Control).gui_input.emit(event)


func test_every_star_is_a_big_hit_target_on_the_stage() -> void:
	var view: RewardView = _view(5)
	var stage: Rect2 = Rect2(Vector2.ZERO, Vector2(1920, 1080))
	for id: String in view.template.remaining():
		var star: Control = view.get_node(id) as Control
		assert_true(star.is_in_group("hit_target"))
		assert_gte(star.size.x, 120.0)
		assert_true(stage.encloses(Rect2(star.position, star.size)), "%s is on the stage" % id)


func test_stars_do_not_overlap() -> void:
	var view: RewardView = _view(6)
	var rects: Array[Rect2] = []
	for id: String in view.template.remaining():
		var star: Control = view.get_node(id) as Control
		rects.append(Rect2(star.position, star.size))
	for first: int in rects.size():
		for second: int in range(first + 1, rects.size()):
			assert_false(rects[first].intersects(rects[second]))


func test_a_tap_collects_the_star() -> void:
	var view: RewardView = _view()
	watch_signals(view.template)
	_tap(view, "star_0")
	assert_signal_emitted(view.template, "hit")
	assert_eq((view.get_node("star_0") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_a_synthesized_mouse_event_is_dropped() -> void:
	var view: RewardView = _view()
	watch_signals(view.template)
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.pressed = true
	event.device = -1
	(view.get_node("star_0") as Control).gui_input.emit(event)
	assert_signal_not_emitted(view.template, "hit")


func test_collecting_all_completes() -> void:
	var view: RewardView = _view(2)
	watch_signals(view.template)
	_tap(view, "star_0")
	_tap(view, "star_1")
	assert_signal_emitted(view.template, "completed")


func test_the_hint_pulses_a_star_and_stops_clean() -> void:
	var view: RewardView = _view()
	view.set_hint(true)
	view.set_hint(false)
	assert_eq((view.get_node("star_0") as Control).scale, Vector2.ONE)
