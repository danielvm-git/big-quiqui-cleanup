class_name MapTemplate
extends StepTemplate
## t25_map: the hub. Tap a room to open it. It fits one screen, so there is no pan yet.
## A lock opens with play, never with payment. The map never completes by itself:
## leaving it is choosing a room. Params: rooms (Array of {id, rect}), clean (Array of ids).

signal room_chosen(room_id: String)

var _rects: Dictionary = {}
var _order: Array[String] = []
var _clean: Dictionary = {}


func setup(params: Dictionary) -> void:
	super.setup(params)
	_rects.clear()
	_order.clear()
	_clean.clear()
	for room: Variant in params.get("rooms", []) as Array:
		var entry: Dictionary = room as Dictionary
		_rects[str(entry["id"])] = entry["rect"] as Rect2
		_order.append(str(entry["id"]))
	for id: Variant in params.get("clean", []) as Array:
		_clean[str(id)] = true


func room_at(point: Vector2) -> String:
	for id: String in _order:
		if (_rects[id] as Rect2).has_point(point):
			return id
	return ""


func choose_at(point: Vector2) -> bool:
	return choose_room(room_at(point))


func choose_room(room_id: String) -> bool:
	if not _rects.has(room_id):
		return false
	hit.emit()
	room_chosen.emit(room_id)
	return true


func set_clean(room_id: String, clean: bool) -> void:
	if clean:
		_clean[room_id] = true
	else:
		_clean.erase(room_id)


func is_clean(room_id: String) -> bool:
	return _clean.has(room_id)


func all_clean() -> bool:
	return not _order.is_empty() and _clean.size() == _order.size()
