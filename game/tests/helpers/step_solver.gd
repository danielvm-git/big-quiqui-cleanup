# story: e02s07
class_name StepSolver
extends RefCounted
## Finishes any step the way a child would, but through the template API, so flow tests
## need no scene-specific code (headless viewports do not dispatch GUI input).


static func solve(template: StepTemplate, params: Dictionary) -> void:
	if template is EraseTemplate:
		_scrub(template as EraseTemplate, params["layer_rect"] as Rect2)
	elif template is DragSnapTemplate:
		var drag: DragSnapTemplate = template as DragSnapTemplate
		for id: String in drag.remaining():
			drag.pick(id)
			drag.drop((params["target_rect"] as Rect2).get_center())
	elif template is TouchEachTemplate:
		var touches: TouchEachTemplate = template as TouchEachTemplate
		for id: String in touches.remaining():
			touches.touch(id)


static func _scrub(erase: EraseTemplate, rect: Rect2) -> void:
	var y: float = rect.position.y
	while not erase.is_done():
		erase.rub_begin(Vector2(rect.position.x, y))
		erase.rub_to(Vector2(rect.end.x, y))
		erase.rub_end()
		y += 20.0
		if y > rect.end.y:
			y = rect.position.y
