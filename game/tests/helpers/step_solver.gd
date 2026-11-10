# story: e02s07
class_name StepSolver
extends RefCounted
## Finishes any step the way a child would, but through the template API, so flow tests
## need no scene-specific code (headless viewports do not dispatch GUI input).


static func solve(template: StepTemplate, params: Dictionary) -> void:
	if template is EraseTemplate:
		_scrub(template as EraseTemplate)
	elif template is DragSnapTemplate:
		var drag: DragSnapTemplate = template as DragSnapTemplate
		for id: String in drag.remaining():
			drag.pick(id)
			drag.drop((params["target_rect"] as Rect2).get_center())
	elif template is TouchEachTemplate:
		var touches: TouchEachTemplate = template as TouchEachTemplate
		for id: String in touches.remaining():
			touches.touch(id)


## Rubs the rows of the template's own rect until done. It gives up after 200 passes: a test
## that cannot finish must fail, never hang.
static func _scrub(erase: EraseTemplate) -> void:
	var rect: Rect2 = erase.layer_rect()
	var y: float = rect.position.y
	var guard: int = 0
	while not erase.is_done() and guard < 200:
		erase.rub_begin(Vector2(rect.position.x, y))
		erase.rub_to(Vector2(rect.end.x, y))
		erase.rub_end()
		y += 20.0
		guard += 1
		if y > rect.end.y:
			y = rect.position.y
