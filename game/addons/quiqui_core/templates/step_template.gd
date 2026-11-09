class_name StepTemplate
extends RefCounted
## Base of every template (L2). A template runs one loop of one step: gesture, test, answer.
## It knows nothing about the game. Charter: a miss never punishes, no timer ends a step.

signal hit
signal miss
signal completed

var _done: bool = false


func setup(_params: Dictionary) -> void:
	_done = false


func is_done() -> bool:
	return _done


## Feeds one raw input event. Synthesized mouse events (device -1) are dropped (rule 7).
func handle_input(_event: InputEvent) -> void:
	pass


static func is_echo(event: InputEvent) -> bool:
	return event is InputEventMouse and (event as InputEventMouse).device == -1


func _finish() -> void:
	if _done:
		return
	_done = true
	completed.emit()
