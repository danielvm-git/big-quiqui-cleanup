class_name DragSnapTemplate
extends StepTemplate
## t20_drag_snap: carry each item to the target. Done when every item is delivered.
## A miss returns the item to the tray. Params: items (Array of ids), target_rect (Rect2).

var held: String = ""

var _tray: Array[String] = []
var _target: Rect2 = Rect2()


func setup(params: Dictionary) -> void:
	super.setup(params)
	_target = params.get("target_rect", Rect2()) as Rect2
	_tray.clear()
	for id: Variant in params.get("items", []) as Array:
		_tray.append(str(id))
	held = ""


func remaining() -> Array[String]:
	return _tray.duplicate()


func pick(item_id: String) -> bool:
	if held != "" or not _tray.has(item_id):
		return false
	held = item_id
	return true


## Ends the carry. Returns true when the item was delivered.
func drop(point: Vector2) -> bool:
	if held == "":
		return false
	var delivered: bool = _target.has_point(point)
	var item: String = held
	held = ""
	if delivered:
		_tray.erase(item)
		hit.emit()
		if _tray.is_empty():
			_finish()
	else:
		miss.emit()
	return delivered
