class_name ScenePlayer
extends RefCounted
## The state machine of the one player (ADR-001): LOAD, INTRO, STEP, STEP_DONE, OUTRO, EXIT.
## It holds order, not pixels. Home leaves from every state. No state has a dwell limit.

signal step_started(index: int, step: StepDef)
signal exited(next_scene: String)

const LOAD: String = "LOAD"
const INTRO: String = "INTRO"
const STEP: String = "STEP"
const STEP_DONE: String = "STEP_DONE"
const OUTRO: String = "OUTRO"
const EXIT: String = "EXIT"

const EDGES: Dictionary = {
	"LOAD": ["INTRO", "EXIT"],
	"INTRO": ["STEP", "EXIT"],
	"STEP": ["STEP_DONE", "EXIT"],
	"STEP_DONE": ["STEP", "OUTRO", "EXIT"],
	"OUTRO": ["EXIT"],
	"EXIT": ["LOAD"],
}

var fsm: Fsm = Fsm.new(LOAD, EDGES)
var scene: SceneDef = null
var step_index: int = 0
var exit_target: String = ""
var errors: PackedStringArray = PackedStringArray()


func load_scene(def: SceneDef) -> bool:
	errors = def.validate()
	if not errors.is_empty():
		return false
	scene = def
	restart()
	return true


func state() -> String:
	return fsm.state


func current_step() -> StepDef:
	if scene == null or step_index >= scene.steps.size():
		return null
	return scene.steps[step_index]


## Moves forward one state. From STEP_DONE it starts the next step or the outro.
func advance() -> void:
	match fsm.state:
		LOAD:
			fsm.transition_to(INTRO)
		INTRO:
			_begin_step()
		STEP_DONE:
			_after_step()
		OUTRO:
			_leave(scene.next)


func step_finished() -> void:
	if fsm.state == STEP:
		fsm.transition_to(STEP_DONE)


func go_home() -> void:
	_leave("")


## Leaves for another scene by id (the map uses this to open a room).
func leave_to(target: String) -> void:
	_leave(target)


func restart() -> void:
	step_index = 0
	exit_target = ""
	fsm.reset(LOAD)


func _begin_step() -> void:
	if fsm.transition_to(STEP):
		step_started.emit(step_index, scene.steps[step_index])


func _after_step() -> void:
	if step_index + 1 < scene.steps.size():
		step_index += 1
		_begin_step()
	else:
		fsm.transition_to(OUTRO)


func _leave(target: String) -> void:
	if fsm.transition_to(EXIT):
		exit_target = target
		exited.emit(target)
