class_name FsmProbe
extends RefCounted
## Records what an `Fsm` actually did, so a test asserts behavior instead of trusting
## the machine's own opinion.

const MAX_HISTORY: int = 64

var transitions: Array[String] = []
var rejections: Array[Dictionary] = []
var timeouts: Array[String] = []

var _fsm: Fsm = null


func attach(fsm: Fsm) -> FsmProbe:
	if _fsm != null:
		detach()
	_fsm = fsm
	_fsm.transitioned.connect(_on_transitioned)
	_fsm.rejected.connect(_on_rejected)
	_fsm.dwell_timeout.connect(_on_timeout)
	return self


func detach() -> void:
	if _fsm == null:
		return
	if _fsm.transitioned.is_connected(_on_transitioned):
		_fsm.transitioned.disconnect(_on_transitioned)
	if _fsm.rejected.is_connected(_on_rejected):
		_fsm.rejected.disconnect(_on_rejected)
	if _fsm.dwell_timeout.is_connected(_on_timeout):
		_fsm.dwell_timeout.disconnect(_on_timeout)
	_fsm = null


func is_clean() -> bool:
	return rejections.is_empty() and timeouts.is_empty()


func transition_count() -> int:
	return transitions.size()


func last_transition() -> String:
	if transitions.is_empty():
		return ""
	return transitions.back()


func summary() -> String:
	return "transitions=%s rejections=%s timeouts=%s" % [transitions, rejections, timeouts]


func _on_transitioned(from_state: String, to_state: String) -> void:
	transitions.append("%s->%s" % [from_state, to_state])
	if transitions.size() > MAX_HISTORY:
		transitions.pop_front()


func _on_rejected(from_state: String, to_state: String, reason: String) -> void:
	rejections.append({"from": from_state, "to": to_state, "reason": reason})
	if rejections.size() > MAX_HISTORY:
		rejections.pop_front()


func _on_timeout(state: String) -> void:
	timeouts.append(state)
	if timeouts.size() > MAX_HISTORY:
		timeouts.pop_front()
