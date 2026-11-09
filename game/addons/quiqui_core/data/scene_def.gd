class_name SceneDef
extends Resource
## A scene as data (ADR-001). The one player runs it; no scene has its own script.

@export var id: String = ""
@export var background: String = ""
@export var music: String = ""
@export var intro_voice: String = ""
@export var quiqui_pose: String = "idle"
@export var steps: Array[StepDef] = []
@export var reward: String = ""
@export var next: String = ""


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if id.is_empty():
		errors.append("scene has no id")
	if steps.is_empty():
		errors.append("scene '%s' has no steps" % id)
	for step: StepDef in steps:
		errors.append_array(step.validate())
	return errors
