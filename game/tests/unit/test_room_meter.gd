# story: e02s04
extends GutTest
## The room meter is a row of dots, one per step, that fill as steps finish.


func _meter(total: int) -> RoomMeter:
	var meter: RoomMeter = RoomMeter.new()
	add_child_autofree(meter)
	meter.configure(total)
	return meter


func test_one_dot_per_step() -> void:
	assert_eq(_meter(3).get_child_count(), 3)


func test_starts_empty() -> void:
	assert_eq(_meter(3).filled(), 0)


func test_fill_shows_that_many_full_dots() -> void:
	var meter: RoomMeter = _meter(3)
	meter.fill(2)
	assert_eq(meter.filled(), 2)
	assert_eq((meter.get_child(0) as TextureRect).texture, Assets.texture("ui/dot_full"))
	assert_eq((meter.get_child(2) as TextureRect).texture, Assets.texture("ui/dot_empty"))


func test_fill_is_clamped() -> void:
	var meter: RoomMeter = _meter(2)
	meter.fill(9)
	assert_eq(meter.filled(), 2)
	meter.fill(-1)
	assert_eq(meter.filled(), 0)


func test_dots_never_take_a_touch() -> void:
	for dot: Node in _meter(2).get_children():
		assert_eq((dot as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
