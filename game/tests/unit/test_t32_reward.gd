# story: e03s03
extends GutTest
## t32_reward: collect every star once. A star is a coin. No timer, no miss.


func _make(count: int = 3) -> RewardTemplate:
	var template: RewardTemplate = RewardTemplate.new()
	template.setup({"stars": count})
	return template


func test_it_starts_with_the_asked_number_of_stars() -> void:
	assert_eq(_make(3).remaining().size(), 3)
	assert_eq(_make(5).remaining().size(), 5)


func test_star_ids_are_stable() -> void:
	assert_eq(RewardTemplate.star_id(0), "star_0")
	assert_eq(_make(2).remaining(), ["star_0", "star_1"] as Array[String])


func test_collecting_a_star_hits_once() -> void:
	var template: RewardTemplate = _make()
	watch_signals(template)
	assert_true(template.touch("star_1"))
	assert_signal_emit_count(template, "hit", 1)
	assert_false(template.remaining().has("star_1"))


func test_a_repeat_is_not_a_miss() -> void:
	var template: RewardTemplate = _make()
	template.touch("star_0")
	watch_signals(template)
	assert_false(template.touch("star_0"))
	assert_signal_not_emitted(template, "miss")
	assert_signal_not_emitted(template, "hit")


func test_the_last_star_completes_it() -> void:
	var template: RewardTemplate = _make(2)
	watch_signals(template)
	template.touch("star_0")
	assert_signal_not_emitted(template, "completed")
	template.touch("star_1")
	assert_signal_emit_count(template, "completed", 1)
	assert_true(template.is_done())


func test_the_count_is_kept_inside_a_sane_range() -> void:
	assert_eq(_make(0).remaining().size(), 1)
	assert_eq(_make(50).remaining().size(), RewardTemplate.MAX_STARS)
