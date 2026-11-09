# story: e02s02
extends GutTest
## t21_touch_each: touch every target once. A repeat touch is harmless. No auto-end timer.


func _make() -> TouchEachTemplate:
	var template: TouchEachTemplate = TouchEachTemplate.new()
	template.setup({"targets": ["lamp", "hat", "plush"]})
	return template


func test_all_targets_start_untouched() -> void:
	assert_eq(_make().remaining().size(), 3)


func test_touching_a_target_hits_once() -> void:
	var template: TouchEachTemplate = _make()
	watch_signals(template)
	assert_true(template.touch("lamp"))
	assert_signal_emit_count(template, "hit", 1)
	assert_false(template.remaining().has("lamp"))


func test_a_repeat_touch_does_nothing_and_is_not_a_miss() -> void:
	var template: TouchEachTemplate = _make()
	template.touch("lamp")
	watch_signals(template)
	assert_false(template.touch("lamp"))
	assert_signal_not_emitted(template, "hit")
	assert_signal_not_emitted(template, "miss")


func test_an_unknown_target_is_ignored() -> void:
	var template: TouchEachTemplate = _make()
	watch_signals(template)
	assert_false(template.touch("car"))
	assert_signal_not_emitted(template, "miss")
	assert_eq(template.remaining().size(), 3)


func test_done_when_every_target_is_touched() -> void:
	var template: TouchEachTemplate = _make()
	watch_signals(template)
	for id: String in ["lamp", "hat", "plush"]:
		template.touch(id)
	assert_true(template.is_done())
	assert_signal_emit_count(template, "completed", 1)


func test_nothing_ends_the_step_but_touching() -> void:
	var template: TouchEachTemplate = _make()
	template.touch("lamp")
	assert_false(template.is_done())
