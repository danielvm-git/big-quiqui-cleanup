class_name ParentGate
extends RefCounted
## A gate a young child cannot pass by tapping: it opens after an unbroken press of `hold_sec`.
## No reading, no arithmetic. States are an Fsm table (IDLE, HOLDING, OPEN). It ends no game step.

signal opened

const IDLE: String = "IDLE"
const HOLDING: String = "HOLDING"
const OPEN: String = "OPEN"
const EDGES: Dictionary = {
	"IDLE": ["HOLDING"],
	"HOLDING": ["IDLE", "OPEN"],
	"OPEN": ["IDLE"],
}
## One frame can count for at most this much, so a hitch cannot skip the hold.
const MAX_STEP_SEC: float = 0.1

var hold_sec: float = 2.5

var _fsm: Fsm = Fsm.new(IDLE, EDGES)
var _held: float = 0.0


func _init(seconds: float = 2.5) -> void:
	hold_sec = maxf(seconds, 0.1)


func state() -> String:
	return _fsm.state


func is_open() -> bool:
	return _fsm.state == OPEN


## How full the ring is, from 0 to 1.
func progress() -> float:
	return clampf(_held / hold_sec, 0.0, 1.0)


func press() -> void:
	if _fsm.state == IDLE:
		_held = 0.0
		_fsm.transition_to(HOLDING)


func release() -> void:
	if _fsm.state == HOLDING:
		_held = 0.0
		_fsm.transition_to(IDLE)


func tick(delta: float) -> void:
	if _fsm.state != HOLDING:
		return
	_held += minf(delta, MAX_STEP_SEC)
	if _held >= hold_sec and _fsm.transition_to(OPEN):
		opened.emit()


func close() -> void:
	_held = 0.0
	if _fsm.state != IDLE:
		_fsm.transition_to(IDLE)
