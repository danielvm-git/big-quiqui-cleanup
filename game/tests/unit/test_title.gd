# story: e04s04
extends GutTest
## t0_title: a play button, and a lock that opens the parent area only after a long hold.


func _view() -> TitleView:
	var view: TitleView = TitleView.new()
	add_child_autofree(view)
	view.configure({})
	return view


func _touch(pressed: bool, device: int = 0) -> InputEventScreenTouch:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.pressed = pressed
	event.position = Vector2(10, 10)
	return event


func _hold_lock(view: TitleView, seconds: float) -> void:
	view.lock_button.gui_input.emit(_touch(true))
	var left: float = seconds
	while left > 0.0:
		view._process(0.05)
		left -= 0.05


func test_play_completes_the_step_once() -> void:
	var template: TitleTemplate = TitleTemplate.new()
	template.setup({})
	watch_signals(template)
	template.play()
	template.play()
	assert_signal_emit_count(template, "hit", 1)
	assert_signal_emit_count(template, "completed", 1)


func test_the_play_button_and_the_lock_are_big_hit_targets_on_the_stage() -> void:
	var view: TitleView = _view()
	var stage: Rect2 = Rect2(0, 0, 1920, 1080)
	for control: Control in [view.play_button, view.lock_button]:
		assert_true(control.is_in_group("hit_target"))
		assert_gte(control.size.x, 120.0)
		assert_gte(control.size.y, 120.0)
		assert_true(stage.encloses(Rect2(control.position, control.size)))


func test_pressing_play_completes_the_title() -> void:
	var view: TitleView = _view()
	watch_signals(view.template)
	view.play_button.pressed.emit()
	assert_signal_emitted(view.template, "completed")


func test_a_tap_on_the_lock_opens_nothing() -> void:
	var view: TitleView = _view()
	view.lock_button.gui_input.emit(_touch(true))
	view._process(0.05)
	view.lock_button.gui_input.emit(_touch(false))
	assert_false(view.panel.visible)


func test_a_short_hold_opens_nothing() -> void:
	var view: TitleView = _view()
	_hold_lock(view, 1.5)
	view.lock_button.gui_input.emit(_touch(false))
	_hold_lock(view, 0.0)
	assert_false(view.panel.visible)
	assert_eq(view.gate.progress(), 0.0)


func test_a_long_hold_opens_the_parent_area() -> void:
	var view: TitleView = _view()
	_hold_lock(view, 2.7)
	assert_true(view.panel.visible)


func test_a_synthesized_mouse_press_does_not_start_the_hold() -> void:
	var view: TitleView = _view()
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.pressed = true
	event.device = -1
	view.lock_button.gui_input.emit(event)
	view._process(0.05)
	assert_eq(view.gate.state(), ParentGate.IDLE)


func test_the_panel_resets_only_on_the_second_press() -> void:
	var view: TitleView = _view()
	_hold_lock(view, 2.7)
	watch_signals(view.template)
	view.panel.reset_button.pressed.emit()
	assert_true(view.panel.is_armed())
	assert_signal_not_emitted(view.template, "reset_requested")
	view.panel.reset_button.pressed.emit()
	assert_signal_emitted(view.template, "reset_requested")
	assert_false(view.panel.is_armed())


func test_closing_the_panel_needs_a_new_hold_to_reopen() -> void:
	var view: TitleView = _view()
	_hold_lock(view, 2.7)
	view.panel.close_button.pressed.emit()
	assert_false(view.panel.visible)
	assert_eq(view.gate.state(), ParentGate.IDLE)
	view.panel.reset_button.pressed.emit()
	view.panel.close_button.pressed.emit()
	assert_false(view.panel.is_armed(), "closing disarms the reset")


func test_the_parent_area_makes_the_offline_promise_in_words() -> void:
	var view: TitleView = _view()
	assert_false(view.panel.note_text().is_empty())


func test_progress_and_house_can_be_reset() -> void:
	var progress: Progress = Progress.new()
	progress.mark_clean("kitchen")
	progress.add_coins(5)
	progress.reset()
	assert_eq(progress.coins, 0)
	assert_eq(progress.clean.size(), 0)
	var house: HouseState = HouseState.new(["kitchen"] as Array[String])
	house.mark_clean("kitchen")
	house.reset()
	assert_eq(house.clean_count(), 0)
