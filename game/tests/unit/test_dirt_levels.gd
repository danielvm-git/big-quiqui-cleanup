# story: e02s03
extends GutTest
## Two dirt levels: the first pass is heavy, the second is lighter, and each needs its own rub.

const LAYER: Rect2 = Rect2(100, 100, 400, 200)


func _view(levels: int) -> DirtView:
	var view: DirtView = DirtView.new()
	add_child_autofree(view)
	view.configure({"layer_rect": LAYER, "cell": 20.0, "radius": 30.0, "levels": levels})
	return view


func _clear_level(view: DirtView) -> void:
	var start: int = view.template.level
	var y: float = LAYER.position.y
	while y <= LAYER.end.y and view.template.level == start:
		view.template.rub_begin(Vector2(LAYER.position.x, y))
		view.template.rub_to(Vector2(LAYER.end.x, y))
		view.template.rub_end()
		y += 20.0


func test_one_level_dust_is_full_strength() -> void:
	assert_almost_eq(_view(1).dust_strength(), 1.0, 0.001)


func test_second_level_is_lighter_than_the_first() -> void:
	var view: DirtView = _view(2)
	var first: float = view.dust_color(0, 0).a
	_clear_level(view)
	assert_eq(view.template.level, 1)
	assert_lt(view.dust_color(0, 0).a, first)


func test_the_second_level_starts_dirty_again() -> void:
	var view: DirtView = _view(2)
	_clear_level(view)
	assert_eq(view.template.coverage(), 0.0)
	assert_false(view.template.is_done())


func test_both_levels_must_be_cleared() -> void:
	var view: DirtView = _view(2)
	_clear_level(view)
	_clear_level(view)
	assert_true(view.template.is_done())
