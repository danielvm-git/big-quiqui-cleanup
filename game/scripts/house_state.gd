class_name HouseState
extends RefCounted
## Which rooms are clean. In memory only for now; saving arrives in slice S3.

var rooms: Array[String] = []

var _clean: Dictionary = {}


func _init(room_ids: Array[String] = []) -> void:
	rooms = room_ids


func mark_clean(room_id: String) -> bool:
	if not rooms.has(room_id):
		return false
	_clean[room_id] = true
	return true


func make_dirty(room_id: String) -> void:
	_clean.erase(room_id)


func is_clean(room_id: String) -> bool:
	return _clean.has(room_id)


func clean_count() -> int:
	return _clean.size()


func all_clean() -> bool:
	return not rooms.is_empty() and _clean.size() == rooms.size()


func clean_ids() -> Array[String]:
	var ids: Array[String] = []
	for room: String in rooms:
		if is_clean(room):
			ids.append(room)
	return ids
