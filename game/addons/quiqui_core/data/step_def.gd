class_name StepDef
extends Resource
## One step of a scene: which template runs, its params and how it answers.

const TEMPLATES: Array[String] = [
	"t0_title",
	"t20_drag_snap",
	"t21_touch_each",
	"t23_erase",
	"t25_map",
	"t32_reward",
	"t34_rub_reveal",
]

@export var template: String = ""
@export var params: Dictionary = {}
@export var on_hit: Array[Reaction] = []
@export var on_miss: Array[Reaction] = []


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not TEMPLATES.has(template):
		errors.append("template '%s' is unknown" % template)
	for reaction: Reaction in on_hit + on_miss:
		errors.append_array(reaction.validate())
	return errors
