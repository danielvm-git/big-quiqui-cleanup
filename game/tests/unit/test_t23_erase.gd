# story: e01s04
extends GutTest
## t23_erase: rub to clear a layer. Done at the threshold. Rubbing outside does nothing.

const LAYER: Rect2 = Rect2(100, 100, 400, 200)


func _make(threshold: float = 0.9, levels: int = 1) -> EraseTemplate:
	var template: EraseTemplate = EraseTemplate.new()
	template.setup({"layer_rect": LAYER, "cell": 20.0, "radius": 30.0, "threshold": threshold, "levels": levels})
	return template


func _scrub_all(template: EraseTemplate) -> void:
	var start_level: int = template.level
	var y: float = LAYER.position.y
	while y <= LAYER.end.y and template.level == start_level and not template.is_done():
		template.rub_begin(Vector2(LAYER.position.x, y))
		template.rub_to(Vector2(LAYER.end.x, y))
		template.rub_end()
		y += 20.0


func test_starts_with_nothing_cleared() -> void:
	assert_eq(_make().coverage(), 0.0)


func test_one_stroke_clears_part_of_the_layer() -> void:
	var template: EraseTemplate = _make()
	template.rub_begin(Vector2(150, 150))
	template.rub_to(Vector2(300, 150))
	assert_gt(template.coverage(), 0.0)
	assert_lt(template.coverage(), 0.9)


func test_rubbing_outside_the_layer_does_nothing() -> void:
	var template: EraseTemplate = _make()
	watch_signals(template)
	template.rub_begin(Vector2(900, 900))
	template.rub_to(Vector2(1000, 900))
	assert_eq(template.coverage(), 0.0)
	assert_signal_not_emitted(template, "hit")
	assert_signal_not_emitted(template, "miss")


func test_a_valid_rub_emits_hit_in_the_same_call() -> void:
	var template: EraseTemplate = _make()
	watch_signals(template)
	template.rub_begin(Vector2(150, 150))
	template.rub_to(Vector2(200, 150))
	assert_signal_emitted(template, "hit")


func test_rubbing_the_same_spot_again_is_not_a_new_hit() -> void:
	var template: EraseTemplate = _make()
	template.rub_begin(Vector2(150, 150))
	template.rub_to(Vector2(200, 150))
	watch_signals(template)
	template.rub_to(Vector2(150, 150))
	template.rub_to(Vector2(200, 150))
	assert_signal_not_emitted(template, "hit")


func test_done_at_the_threshold() -> void:
	var template: EraseTemplate = _make()
	watch_signals(template)
	_scrub_all(template)
	assert_true(template.is_done())
	assert_signal_emit_count(template, "completed", 1)


func test_not_done_just_below_the_threshold() -> void:
	var template: EraseTemplate = _make(1.0)
	template.rub_begin(Vector2(LAYER.position.x, LAYER.position.y))
	template.rub_to(Vector2(LAYER.end.x, LAYER.position.y))
	assert_false(template.is_done())


func test_levels_need_a_fresh_pass_each() -> void:
	var template: EraseTemplate = _make(0.9, 2)
	_scrub_all(template)
	assert_false(template.is_done())
	assert_eq(template.level, 1)
	assert_eq(template.coverage(), 0.0)
	_scrub_all(template)
	assert_true(template.is_done())


func test_a_synthesized_mouse_echo_is_ignored() -> void:
	var template: EraseTemplate = _make()
	var echo: InputEventMouseMotion = InputEventMouseMotion.new()
	echo.device = -1
	echo.position = Vector2(150, 150)
	echo.button_mask = MOUSE_BUTTON_MASK_LEFT
	template.handle_input(echo)
	assert_eq(template.coverage(), 0.0)


func test_a_real_touch_drag_rubs() -> void:
	var template: EraseTemplate = _make()
	var down: InputEventScreenTouch = InputEventScreenTouch.new()
	down.pressed = true
	down.position = Vector2(150, 150)
	template.handle_input(down)
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.position = Vector2(300, 150)
	template.handle_input(drag)
	assert_gt(template.coverage(), 0.0)


func test_the_grid_can_be_read_back_for_drawing() -> void:
	var template: EraseTemplate = _make()
	assert_eq(template.grid_size(), Vector2i(20, 10))
	template.rub_begin(Vector2(110, 110))
	assert_true(template.is_cell_cleared(0, 0))
	assert_false(template.is_cell_cleared(19, 9))


func test_a_lone_tap_reacts_in_the_same_call() -> void:
	var template: EraseTemplate = _make()
	watch_signals(template)
	template.rub_begin(Vector2(150, 150))
	assert_signal_emitted(template, "hit")
	assert_gt(template.coverage(), 0.0)


func test_a_mouse_release_ends_the_rub() -> void:
	var template: EraseTemplate = _make()
	template.rub_begin(Vector2(150, 150))
	var up: InputEventMouseButton = InputEventMouseButton.new()
	up.pressed = false
	up.device = 0
	template.handle_input(up)
	template.rub_to(Vector2(400, 250))
	assert_gt(template.coverage(), 0.0)
