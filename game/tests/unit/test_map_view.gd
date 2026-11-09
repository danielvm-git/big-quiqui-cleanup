# story: e02s05
extends GutTest
## MapView shows a cloud on a dirty room and a sparkle on a clean one.


func _view(clean: Array = []) -> MapView:
	var view: MapView = MapView.new()
	add_child_autofree(view)
	(
		view
		. configure(
			{
				"rooms":
				[
					{"id": "kitchen", "rect": Rect2(100, 100, 300, 200), "art": "backgrounds/kitchen"},
					{"id": "garden", "rect": Rect2(500, 100, 300, 200), "art": "backgrounds/garden"},
				],
				"clean": clean,
			},
		)
	)
	return view


func _badge(view: MapView, id: String) -> TextureRect:
	return view.get_node(id).get_node("badge") as TextureRect


func _press(view: MapView, id: String) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.pressed = true
	event.position = Vector2(10, 10)
	(view.get_node(id) as Control).gui_input.emit(event)


func test_dirty_rooms_show_a_cloud_and_clean_rooms_a_sparkle() -> void:
	var view: MapView = _view(["garden"])
	assert_eq(_badge(view, "kitchen").texture, Assets.texture("effects/foam"))
	assert_eq(_badge(view, "garden").texture, Assets.texture("effects/sparkle"))


func test_every_room_card_is_a_big_hit_target() -> void:
	var view: MapView = _view()
	for id: String in ["kitchen", "garden"]:
		var card: Control = view.get_node(id) as Control
		assert_true(card.is_in_group("hit_target"))
		assert_eq(card.size, Vector2(300, 200))


func test_a_press_chooses_the_room() -> void:
	var view: MapView = _view()
	watch_signals(view.template)
	_press(view, "kitchen")
	assert_signal_emitted_with_parameters(view.template, "room_chosen", ["kitchen"])


func test_an_echo_does_not_count_as_input() -> void:
	var view: MapView = _view()
	watch_signals(view)
	var echo: InputEventMouseButton = InputEventMouseButton.new()
	echo.device = -1
	echo.pressed = true
	(view.get_node("kitchen") as Control).gui_input.emit(echo)
	assert_signal_not_emitted(view, "touched")
	_press(view, "kitchen")
	assert_signal_emitted(view, "touched")


func test_refresh_updates_the_badge() -> void:
	var view: MapView = _view()
	view.template.set_clean("kitchen", true)
	view.refresh()
	assert_eq(_badge(view, "kitchen").texture, Assets.texture("effects/sparkle"))
