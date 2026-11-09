# story: e01s05
extends GutTest
## t20_drag_snap: carry each item to the target. A miss returns the item. Nothing is lost.

const TARGET: Rect2 = Rect2(600, 300, 200, 200)


func _make() -> DragSnapTemplate:
	var template: DragSnapTemplate = DragSnapTemplate.new()
	template.setup({"items": ["bear", "ball", "block"], "target_rect": TARGET})
	return template


func test_all_items_start_in_the_tray() -> void:
	var template: DragSnapTemplate = _make()
	assert_eq(template.remaining().size(), 3)
	assert_eq(template.held, "")


func test_picking_an_item_holds_it() -> void:
	var template: DragSnapTemplate = _make()
	assert_true(template.pick("bear"))
	assert_eq(template.held, "bear")


func test_an_unknown_item_cannot_be_picked() -> void:
	var template: DragSnapTemplate = _make()
	assert_false(template.pick("car"))
	assert_eq(template.held, "")


func test_drop_on_the_target_delivers_and_hits() -> void:
	var template: DragSnapTemplate = _make()
	watch_signals(template)
	template.pick("bear")
	assert_true(template.drop(Vector2(700, 400)))
	assert_signal_emitted(template, "hit")
	assert_false(template.remaining().has("bear"))
	assert_eq(template.held, "")


func test_drop_off_target_returns_the_item_and_misses() -> void:
	var template: DragSnapTemplate = _make()
	watch_signals(template)
	template.pick("bear")
	assert_false(template.drop(Vector2(50, 50)))
	assert_signal_emitted(template, "miss")
	assert_true(template.remaining().has("bear"))
	assert_eq(template.held, "")
	assert_false(template.is_done())


func test_a_missed_item_can_be_picked_again() -> void:
	var template: DragSnapTemplate = _make()
	template.pick("bear")
	template.drop(Vector2(50, 50))
	assert_true(template.pick("bear"))


func test_done_when_every_item_is_delivered() -> void:
	var template: DragSnapTemplate = _make()
	watch_signals(template)
	for id: String in ["bear", "ball", "block"]:
		template.pick(id)
		template.drop(TARGET.get_center())
	assert_true(template.is_done())
	assert_signal_emit_count(template, "completed", 1)


func test_a_delivered_item_cannot_be_picked_again() -> void:
	var template: DragSnapTemplate = _make()
	template.pick("bear")
	template.drop(TARGET.get_center())
	assert_false(template.pick("bear"))


func test_drop_with_nothing_held_does_nothing() -> void:
	var template: DragSnapTemplate = _make()
	watch_signals(template)
	assert_false(template.drop(TARGET.get_center()))
	assert_signal_not_emitted(template, "miss")
	assert_signal_not_emitted(template, "hit")


func test_no_timer_ends_the_step() -> void:
	var template: DragSnapTemplate = _make()
	template.pick("bear")
	assert_false(template.is_done())
	assert_eq(template.held, "bear")


func test_an_abandoned_carry_does_not_lock_the_step() -> void:
	var template: DragSnapTemplate = _make()
	template.pick("bear")
	assert_true(template.pick("ball"))
	assert_eq(template.held, "ball")
