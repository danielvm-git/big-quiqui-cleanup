# story: e02s05
extends GutTest
## t25_map: tap a room to open it. A tap on empty space does nothing. A lock never costs money.


func _make(clean: Array = []) -> MapTemplate:
	var template: MapTemplate = MapTemplate.new()
	(
		template
		. setup(
			{
				"rooms":
				[
					{"id": "kitchen", "rect": Rect2(100, 100, 300, 200)},
					{"id": "garden", "rect": Rect2(500, 100, 300, 200)},
				],
				"clean": clean,
			},
		)
	)
	return template


func test_room_at_finds_the_room_under_a_point() -> void:
	assert_eq(_make().room_at(Vector2(200, 150)), "kitchen")
	assert_eq(_make().room_at(Vector2(600, 150)), "garden")


func test_room_at_is_empty_off_the_rooms() -> void:
	assert_eq(_make().room_at(Vector2(450, 600)), "")


func test_choosing_a_room_emits_hit_and_room_chosen() -> void:
	var template: MapTemplate = _make()
	watch_signals(template)
	assert_true(template.choose_room("garden"))
	assert_signal_emitted_with_parameters(template, "room_chosen", ["garden"])
	assert_signal_emitted(template, "hit")


func test_choosing_an_unknown_room_does_nothing() -> void:
	var template: MapTemplate = _make()
	watch_signals(template)
	assert_false(template.choose_room("attic"))
	assert_signal_not_emitted(template, "room_chosen")
	assert_signal_not_emitted(template, "miss")


func test_a_tap_on_empty_space_is_not_a_miss() -> void:
	var template: MapTemplate = _make()
	watch_signals(template)
	assert_false(template.choose_at(Vector2(450, 600)))
	assert_signal_not_emitted(template, "miss")
	assert_signal_not_emitted(template, "room_chosen")


func test_clean_rooms_come_from_setup_and_can_change() -> void:
	var template: MapTemplate = _make(["kitchen"])
	assert_true(template.is_clean("kitchen"))
	assert_false(template.is_clean("garden"))
	template.set_clean("garden", true)
	assert_true(template.all_clean())


func test_a_clean_room_can_be_opened_again() -> void:
	var template: MapTemplate = _make(["kitchen"])
	assert_true(template.choose_room("kitchen"))


func test_the_map_never_completes_by_itself() -> void:
	var template: MapTemplate = _make(["kitchen", "garden"])
	assert_false(template.is_done())
