class_name Progress
extends RefCounted
## What the house remembers between sessions: which rooms are clean and how many coins.
## Schema version 1. A bad field gives that field's default, never an error or a wrapped number.

const VERSION: int = 1
const MAX_COINS: int = 999_999_999
const MAX_ROOMS: int = 64

var clean: Array[String] = []
var coins: int = 0


## Fields are read one by one: a bad coin count does not throw away the clean rooms.
static func from_dict(data: Dictionary) -> Progress:
	var progress: Progress = Progress.new()
	if not _is_number(data.get("version")) or int(data["version"]) != VERSION:
		return progress
	var coins_value: Variant = data.get("coins")
	if _is_number(coins_value):
		progress.add_coins(int(clampf(float(coins_value), 0.0, float(MAX_COINS))))
	var rooms: Variant = data.get("clean")
	if rooms is Array:
		for room: Variant in rooms as Array:
			if room is String:
				progress.mark_clean(room as String)
	return progress


static func load_from(path: String) -> Progress:
	return from_dict(SaveFile.read(path))


## A save that exists but cannot be read (corrupt, or another version) is moved to "<path>.corrupt"
## so the first new coin does not destroy it. Returns true when it moved a file.
static func keep_unreadable(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var data: Dictionary = SaveFile.read(path)
	if _is_number(data.get("version")) and int(data["version"]) == VERSION:
		return false
	DirAccess.remove_absolute(path + ".corrupt")
	return DirAccess.rename_absolute(path, path + ".corrupt") == OK


static func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and not is_nan(float(value))


func to_dict() -> Dictionary:
	return {"version": VERSION, "coins": coins, "clean": clean}


func save_to(path: String) -> bool:
	return SaveFile.write(path, to_dict())


func reset() -> void:
	clean.clear()
	coins = 0


func add_coins(amount: int) -> void:
	coins = clampi(coins + maxi(amount, 0), 0, MAX_COINS)


func mark_clean(room_id: String) -> void:
	if clean.size() < MAX_ROOMS and not clean.has(room_id):
		clean.append(room_id)


## Marks in the house every saved room it knows. A room the house no longer has is ignored.
func apply_to(house: HouseState) -> void:
	for room: String in clean:
		house.mark_clean(room)
