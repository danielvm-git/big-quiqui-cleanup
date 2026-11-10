# story: e04s03
extends GutTest
## t34_rub_reveal: rub a hazy "before" layer away to show the clean room. Done at the threshold, no timer.

const RECT: Rect2 = Rect2(0, 0, 1920, 1080)
const PARAMS: Dictionary = {
	"layer_rect": RECT, "cell": 40.0, "radius": 100.0, "threshold": 0.7, "levels": 1, "before": "before/garden"
}
const ROOMS: Array[String] = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]


func _view() -> RevealView:
	var view: RevealView = RevealView.new()
	add_child_autofree(view)
	view.configure(PARAMS)
	return view


func _rub_rows(template: EraseTemplate, rows: int) -> void:
	var y: float = 0.0
	for row: int in rows:
		template.rub_begin(Vector2(0, y))
		template.rub_to(Vector2(1920, y))
		template.rub_end()
		y += 100.0


func test_it_is_an_erase_template_with_its_own_threshold() -> void:
	var template: RevealTemplate = RevealTemplate.new()
	template.setup(PARAMS)
	assert_true(template is EraseTemplate)
	_rub_rows(template, 4)
	assert_false(template.is_done())
	_rub_rows(template, 12)
	assert_true(template.is_done())


func test_the_before_layer_is_there_until_the_reveal_is_done() -> void:
	var view: RevealView = _view()
	assert_false(view.is_revealed())
	assert_not_null(view.before_texture())
	_rub_rows(view.template, 12)
	assert_true(view.is_revealed())


func test_a_synthesized_mouse_event_is_dropped() -> void:
	var view: RevealView = _view()
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.pressed = true
	event.device = -1
	event.position = Vector2(500, 500)
	view._gui_input(event)
	assert_eq(view.template.coverage(), 0.0)


func test_a_touch_rubs_cells_away() -> void:
	var view: RevealView = _view()
	var touch: InputEventScreenTouch = InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(500, 500)
	view._gui_input(touch)
	assert_gt(view.template.coverage(), 0.0)


func test_every_room_ends_with_a_reveal_that_has_its_art() -> void:
	for id: String in ROOMS:
		var def: SceneDef = load("res://data/scenes/%s.tres" % id) as SceneDef
		var last: StepDef = def.steps[def.steps.size() - 1]
		assert_eq(last.template, "t34_rub_reveal", id)
		assert_not_null(Assets.texture(str(last.params["before"])), id)
		assert_eq(last.params["layer_rect"], RECT)
