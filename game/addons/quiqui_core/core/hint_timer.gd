class_name HintTimer
extends RefCounted
## Charter rule 5: a hint (ghost hand) shows after a few seconds with no input.
## It only asks the view to show or hide a hint. It never ends or fails a step.

signal hint_shown
signal hint_hidden

var idle_sec: float = 0.0

var _after_sec: float = 4.0
var _showing: bool = false
var _stopped: bool = false


func _init(after_sec: float = 4.0) -> void:
	_after_sec = after_sec


func tick(delta: float) -> void:
	if _stopped or _showing:
		return
	idle_sec += delta
	if idle_sec >= _after_sec:
		_showing = true
		hint_shown.emit()


func notify_input() -> void:
	idle_sec = 0.0
	if _showing:
		_showing = false
		hint_hidden.emit()


func is_showing() -> bool:
	return _showing


func stop() -> void:
	_stopped = true
	notify_input()
