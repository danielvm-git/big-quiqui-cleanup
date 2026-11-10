class_name Progress
extends RefCounted
## What the house remembers between sessions: which rooms are clean and how many coins.
## Schema version 1. Anything unexpected on disk gives a fresh progress, never an error.

const VERSION: int = 1

var clean: Array[String] = []
var coins: int = 0


static func from_dict(data: Dictionary) -> Progress:
	var progress: Progress = Progress.new()
	if not _valid(data):
		return progress
	progress.coins = int(data["coins"])
	for room: Variant in data["clean"] as Array:
		progress.mark_clean(str(room))
	return progress


static func load_from(path: String) -> Progress:
	return from_dict(SaveFile.read(path))


static func _valid(data: Dictionary) -> bool:
	var version: Variant = data.get("version")
	if not (version is int or version is float) or int(version) != VERSION:
		return false
	var coins_value: Variant = data.get("coins")
	if not (coins_value is int or coins_value is float) or float(coins_value) < 0.0:
		return false
	var rooms: Variant = data.get("clean")
	if not rooms is Array:
		return false
	for room: Variant in rooms as Array:
		if not room is String:
			return false
	return true


func to_dict() -> Dictionary:
	return {"version": VERSION, "coins": coins, "clean": clean}


func save_to(path: String) -> bool:
	return SaveFile.write(path, to_dict())


func add_coins(amount: int) -> void:
	coins += maxi(amount, 0)


func mark_clean(room_id: String) -> void:
	if not clean.has(room_id):
		clean.append(room_id)


## Marks in the house every saved room it knows. A room the house no longer has is ignored.
func apply_to(house: HouseState) -> void:
	for room: String in clean:
		house.mark_clean(room)
