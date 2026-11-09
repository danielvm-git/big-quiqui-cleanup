# story: e02s04
extends GutTest
## HouseState remembers which rooms are clean, in memory only (the save is slice S3).

const ROOMS: Array[String] = ["living_room", "kitchen", "bathroom"]


func _house() -> HouseState:
	return HouseState.new(ROOMS)


func test_every_room_starts_dirty() -> void:
	var house: HouseState = _house()
	assert_eq(house.clean_count(), 0)
	assert_false(house.is_clean("kitchen"))


func test_marking_a_room_clean_is_remembered() -> void:
	var house: HouseState = _house()
	assert_true(house.mark_clean("kitchen"))
	assert_true(house.is_clean("kitchen"))
	assert_eq(house.clean_count(), 1)


func test_an_unknown_room_is_refused() -> void:
	var house: HouseState = _house()
	assert_false(house.mark_clean("attic"))
	assert_eq(house.clean_count(), 0)


func test_marking_twice_does_not_double_count() -> void:
	var house: HouseState = _house()
	house.mark_clean("kitchen")
	house.mark_clean("kitchen")
	assert_eq(house.clean_count(), 1)


func test_all_clean_when_every_room_is_clean() -> void:
	var house: HouseState = _house()
	for room: String in ROOMS:
		house.mark_clean(room)
	assert_true(house.all_clean())


func test_a_room_can_be_made_dirty_again_for_a_replay() -> void:
	var house: HouseState = _house()
	house.mark_clean("kitchen")
	house.make_dirty("kitchen")
	assert_false(house.is_clean("kitchen"))


func test_clean_ids_keeps_the_room_order() -> void:
	var house: HouseState = _house()
	house.mark_clean("bathroom")
	house.mark_clean("living_room")
	assert_eq(house.clean_ids(), ["living_room", "bathroom"] as Array[String])
