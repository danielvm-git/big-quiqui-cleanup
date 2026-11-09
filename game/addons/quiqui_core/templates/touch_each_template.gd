class_name TouchEachTemplate
extends StepTemplate
## t21_touch_each: touch every target once. Done when none is left.
## The TutoTOONS auto-end timer is dropped (ADR-004). A repeat touch is not a miss.
## Params: targets (Array of ids).

var _left: Array[String] = []


func setup(params: Dictionary) -> void:
	super.setup(params)
	_left.clear()
	for id: Variant in params.get("targets", []) as Array:
		_left.append(str(id))


func remaining() -> Array[String]:
	return _left.duplicate()


## Returns true when the touch was the first one on that target.
func touch(target_id: String) -> bool:
	if not _left.has(target_id):
		return false
	_left.erase(target_id)
	hit.emit()
	if _left.is_empty():
		_finish()
	return true
