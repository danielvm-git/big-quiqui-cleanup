extends GutTest
## The Fsm only walks declared edges, is idempotent on the same state, refuses stale
## post-await transitions, and times out exactly once per visit.

const EDGES: Dictionary = {
	"IDLE": ["FEED", "BATH"],
	"FEED": ["IDLE"],
	"BATH": ["IDLE"],
}
const DWELL: Dictionary = {"FEED": 2.0}


class FakeClock:
	var now_ms: int = 0

	func read_ms() -> int:
		return now_ms

	func advance(ms: int) -> void:
		now_ms += ms


func _make(clock: FakeClock = null) -> Fsm:
	var callable: Callable = Callable()
	if clock != null:
		callable = Callable(clock, "read_ms")
	return Fsm.new("IDLE", EDGES, DWELL, callable)


func test_declared_edge_transitions_and_probe_stays_clean() -> void:
	var fsm: Fsm = _make()
	var probe: FsmProbe = FsmProbe.new().attach(fsm)

	assert_true(fsm.transition_to("FEED"), "declared edge must be accepted")
	assert_eq(fsm.state, "FEED")
	assert_true(probe.is_clean(), probe.summary())
	assert_eq(probe.last_transition(), "IDLE->FEED")
	probe.detach()


func test_undeclared_edge_is_rejected() -> void:
	var fsm: Fsm = _make()
	var probe: FsmProbe = FsmProbe.new().attach(fsm)

	assert_false(fsm.transition_to("SLEEP"), "undeclared edge must be refused")
	assert_eq(fsm.state, "IDLE", "state must not move")
	assert_eq(probe.rejections.size(), 1, probe.summary())
	assert_eq(probe.rejections[0]["reason"], Fsm.REASON_ILLEGAL)
	assert_eq(probe.transition_count(), 0)
	probe.detach()


func test_same_state_is_a_silent_noop() -> void:
	var fsm: Fsm = _make()
	var probe: FsmProbe = FsmProbe.new().attach(fsm)

	assert_false(fsm.transition_to("IDLE"), "same-state transition returns false")
	assert_eq(probe.transition_count(), 0, "no transition signal")
	assert_true(probe.is_clean(), "and it is not a rejection either")
	probe.detach()


func test_transition_from_refuses_a_stale_expectation() -> void:
	var fsm: Fsm = _make()
	var probe: FsmProbe = FsmProbe.new().attach(fsm)

	assert_true(fsm.transition_to("FEED"))
	assert_false(fsm.transition_from("IDLE", "BATH"), "expected state is stale")
	assert_eq(fsm.state, "FEED", "the stale attempt must not move the machine")
	assert_eq(probe.rejections.back()["reason"], Fsm.REASON_STALE)
	probe.detach()


func test_dwell_timeout_fires_exactly_once() -> void:
	var clock: FakeClock = FakeClock.new()
	var fsm: Fsm = _make(clock)
	var probe: FsmProbe = FsmProbe.new().attach(fsm)

	assert_true(fsm.transition_to("FEED"))
	clock.advance(500)
	assert_false(fsm.check_dwell(), "under the limit must not fire")

	clock.advance(1600)
	assert_true(fsm.check_dwell(), "past 2.0 s must fire")
	assert_false(fsm.check_dwell(), "and only once per visit")
	assert_eq(probe.timeouts.size(), 1)
	probe.detach()


func test_dwell_rearms_on_a_new_visit() -> void:
	var clock: FakeClock = FakeClock.new()
	var fsm: Fsm = _make(clock)
	var probe: FsmProbe = FsmProbe.new().attach(fsm)

	fsm.transition_to("FEED")
	clock.advance(2100)
	assert_true(fsm.check_dwell(), "first visit fires")
	fsm.transition_to("IDLE")
	fsm.transition_to("FEED")
	clock.advance(2100)
	assert_true(fsm.check_dwell(), "second visit fires again")
	assert_eq(probe.timeouts.size(), 2)
	probe.detach()


func test_probe_detach_stops_recording() -> void:
	var fsm: Fsm = _make()
	var probe: FsmProbe = FsmProbe.new().attach(fsm)
	probe.detach()

	fsm.transition_to("FEED")
	assert_eq(probe.transition_count(), 0, "detached probe records nothing")


func test_reset_clears_the_visit() -> void:
	var clock: FakeClock = FakeClock.new()
	var fsm: Fsm = _make(clock)

	fsm.transition_to("FEED")
	clock.advance(2100)
	fsm.reset("IDLE")
	assert_eq(fsm.state, "IDLE")
	assert_false(fsm.check_dwell(), "IDLE has no dwell limit")
	assert_eq(fsm.elapsed_sec(), 0.0)
