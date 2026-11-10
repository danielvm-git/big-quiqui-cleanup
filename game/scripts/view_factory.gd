class_name ViewFactory
extends RefCounted
## Builds the view of a step from its template id. The template ids are the only switch.

## Templates with a view. A variable, so a test can take one away to check the guard.
static var supported: Array[String] = [
	"t20_drag_snap", "t21_touch_each", "t23_erase", "t25_map", "t32_reward", "t34_rub_reveal", "t0_title"
]


static func supports(template: String) -> bool:
	return supported.has(template)


static func make(step: StepDef, clean_rooms: Array[String]) -> Control:
	var params: Dictionary = step.params
	var view: Control = _new_view(step.template)
	if view == null:
		push_error("no view for template %s" % step.template)
		return null
	if step.template == "t25_map":
		params = params.duplicate()
		params["clean"] = clean_rooms
	view.call("configure", params)
	return view


static func _new_view(template: String) -> Control:
	match template:
		"t23_erase":
			return DirtView.new()
		"t20_drag_snap":
			return ToyView.new()
		"t21_touch_each":
			return TouchView.new()
		"t32_reward":
			return RewardView.new()
		"t0_title":
			return TitleView.new()
		"t34_rub_reveal":
			return RevealView.new()
		"t25_map":
			return MapView.new()
	return null
