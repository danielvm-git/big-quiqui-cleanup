# story: e01s07
extends GutTest
## The views route real events: echoes are dropped, a release outside the target slides the toy home.

const TARGET: Rect2 = Rect2(600, 300, 200, 200)


func _dirt() -> DirtView:
	var view: DirtView = DirtView.new()
	add_child_autofree(view)
	view.configure({"layer_rect": Rect2(100, 100, 400, 200), "cell": 20.0, "radius": 30.0})
	return view


func _toys() -> ToyView:
	var view: ToyView = ToyView.new()
	add_child_autofree(view)
	var params: Dictionary = {"items": ["ball"], "homes": {"ball": Vector2(200, 700)}, "target_rect": TARGET}
	view.configure(params)
	return view


func _touch(pressed: bool, position: Vector2) -> InputEventScreenTouch:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.pressed = pressed
	event.position = position
	return event


func test_dirt_view_drops_a_synthesized_mouse_echo() -> void:
	var view: DirtView = _dirt()
	watch_signals(view)
	var echo: InputEventMouseMotion = InputEventMouseMotion.new()
	echo.device = -1
	echo.position = Vector2(150, 150)
	echo.button_mask = MOUSE_BUTTON_MASK_LEFT
	view._gui_input(echo)
	assert_signal_not_emitted(view, "touched")
	assert_eq(view.template.coverage(), 0.0)


func test_dirt_view_rubs_on_a_touch_drag() -> void:
	var view: DirtView = _dirt()
	view._gui_input(_touch(true, Vector2(150, 150)))
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.position = Vector2(400, 150)
	view._gui_input(drag)
	assert_gt(view.template.coverage(), 0.0)


func test_toy_view_ignores_an_echo_and_stays_calm() -> void:
	var view: ToyView = _toys()
	watch_signals(view)
	var echo: InputEventMouseButton = InputEventMouseButton.new()
	echo.device = -1
	echo.pressed = true
	var toy: TextureRect = view.get_child(0) as TextureRect
	toy.gui_input.emit(echo)
	assert_signal_not_emitted(view, "touched")
	assert_eq(view.template.held, "")


func test_a_release_off_target_returns_the_toy() -> void:
	var view: ToyView = _toys()
	var toy: TextureRect = view.get_child(0) as TextureRect
	toy.gui_input.emit(_touch(true, Vector2(10, 10)))
	assert_eq(view.template.held, "ball")
	toy.gui_input.emit(_touch(false, Vector2(10, 10)))
	assert_eq(view.template.held, "")
	assert_true(view.template.remaining().has("ball"))


func test_a_release_on_target_delivers_and_frees_the_touch() -> void:
	var view: ToyView = _toys()
	var toy: TextureRect = view.get_child(0) as TextureRect
	toy.gui_input.emit(_touch(true, Vector2(10, 10)))
	var on_target: Vector2 = TARGET.get_center() - toy.global_position
	toy.gui_input.emit(_touch(false, on_target))
	assert_eq(view.template.remaining().size(), 0)
	assert_eq(toy.mouse_filter, Control.MOUSE_FILTER_IGNORE)
