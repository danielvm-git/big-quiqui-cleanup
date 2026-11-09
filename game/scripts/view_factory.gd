class_name ViewFactory
extends RefCounted
## Builds the view of a step from its template id. The template ids are the only switch.


static func make(step: StepDef, clean_rooms: Array[String]) -> Control:
	var params: Dictionary = step.params
	var view: Control = null
	match step.template:
		"t23_erase":
			view = DirtView.new()
		"t20_drag_snap":
			view = ToyView.new()
		"t21_touch_each":
			view = TouchView.new()
		"t25_map":
			view = MapView.new()
			params = params.duplicate()
			params["clean"] = clean_rooms
		_:
			push_error("no view for template %s" % step.template)
			return null
	view.call("configure", params)
	return view
