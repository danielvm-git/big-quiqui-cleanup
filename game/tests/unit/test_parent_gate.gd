# story: e04s02
extends GutTest
## The parent gate opens only after an unbroken hold. A tap, a short press or a hitch never opens it.


func _gate() -> ParentGate:
	return ParentGate.new(2.5)


func _hold(gate: ParentGate, seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		gate.tick(0.05)
		left -= 0.05


func test_it_starts_closed_and_idle() -> void:
	var gate: ParentGate = _gate()
	assert_eq(gate.state(), ParentGate.IDLE)
	assert_eq(gate.progress(), 0.0)


func test_a_tap_does_nothing() -> void:
	var gate: ParentGate = _gate()
	gate.press()
	gate.release()
	assert_eq(gate.state(), ParentGate.IDLE)


func test_a_short_hold_resets_when_released() -> void:
	var gate: ParentGate = _gate()
	gate.press()
	_hold(gate, 2.0)
	assert_gt(gate.progress(), 0.5)
	gate.release()
	assert_eq(gate.progress(), 0.0)
	gate.press()
	_hold(gate, 1.0)
	assert_false(gate.is_open())


func test_an_unbroken_hold_opens_once() -> void:
	var gate: ParentGate = _gate()
	watch_signals(gate)
	gate.press()
	_hold(gate, 2.6)
	assert_true(gate.is_open())
	assert_signal_emit_count(gate, "opened", 1)
	_hold(gate, 1.0)
	assert_signal_emit_count(gate, "opened", 1)


func test_a_frame_hitch_cannot_skip_the_hold() -> void:
	var gate: ParentGate = _gate()
	gate.press()
	gate.tick(10.0)
	assert_false(gate.is_open())


func test_time_without_a_press_counts_for_nothing() -> void:
	var gate: ParentGate = _gate()
	_hold(gate, 5.0)
	gate.press()
	_hold(gate, 1.0)
	assert_false(gate.is_open())


func test_close_returns_to_idle_and_needs_a_new_hold() -> void:
	var gate: ParentGate = _gate()
	gate.press()
	_hold(gate, 2.6)
	gate.close()
	assert_eq(gate.state(), ParentGate.IDLE)
	gate.press()
	_hold(gate, 1.0)
	assert_false(gate.is_open())


func test_releasing_an_open_gate_keeps_it_open() -> void:
	var gate: ParentGate = _gate()
	gate.press()
	_hold(gate, 2.6)
	gate.release()
	assert_true(gate.is_open())
