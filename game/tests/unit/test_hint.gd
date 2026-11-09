# story: e01s06
extends GutTest
## The hint shows after a few seconds with no input, hides on input and never ends a step.


func test_no_hint_before_the_idle_time() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	watch_signals(hint)
	hint.tick(3.9)
	assert_signal_not_emitted(hint, "hint_shown")
	assert_false(hint.is_showing())


func test_hint_shows_once_after_the_idle_time() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	watch_signals(hint)
	hint.tick(4.0)
	hint.tick(10.0)
	assert_signal_emit_count(hint, "hint_shown", 1)
	assert_true(hint.is_showing())


func test_input_resets_the_idle_time() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	watch_signals(hint)
	hint.tick(3.0)
	hint.notify_input()
	hint.tick(3.0)
	assert_signal_not_emitted(hint, "hint_shown")


func test_input_hides_a_showing_hint() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	hint.tick(5.0)
	watch_signals(hint)
	hint.notify_input()
	assert_signal_emitted(hint, "hint_hidden")
	assert_false(hint.is_showing())


func test_hint_can_show_again_after_new_idle() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	hint.tick(5.0)
	hint.notify_input()
	watch_signals(hint)
	hint.tick(5.0)
	assert_signal_emitted(hint, "hint_shown")


func test_stopped_hint_never_shows() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	hint.stop()
	watch_signals(hint)
	hint.tick(100.0)
	assert_signal_not_emitted(hint, "hint_shown")


func test_the_hint_has_no_way_to_end_a_step() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	assert_false(hint.has_signal("completed"))
	assert_false(hint.has_signal("timeout"))


func test_start_rearms_a_stopped_hint() -> void:
	var hint: HintTimer = HintTimer.new(4.0)
	hint.stop()
	hint.start()
	watch_signals(hint)
	hint.tick(5.0)
	assert_signal_emitted(hint, "hint_shown")
