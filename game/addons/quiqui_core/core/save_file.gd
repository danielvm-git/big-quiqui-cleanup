class_name SaveFile
extends RefCounted
## One JSON dictionary on disk. The old file is never deleted before the new one is whole:
## write "<path>.tmp", move the old file to "<path>.bak", move the new one in, then drop the backup.
## A crash at any point leaves a readable file (the main one or the backup).
## The path is an argument: the core knows no game path.

## A save larger than this is not read. Real saves are a few hundred bytes.
const MAX_BYTES: int = 65536


static func write(path: String, data: Dictionary) -> bool:
	var temp: String = path + ".tmp"
	if not _write_whole(temp, JSON.stringify(data)):
		DirAccess.remove_absolute(temp)
		return false
	var backup: String = path + ".bak"
	var had_old: bool = FileAccess.file_exists(path)
	if had_old and DirAccess.rename_absolute(path, backup) != OK:
		DirAccess.remove_absolute(temp)
		return false
	if DirAccess.rename_absolute(temp, path) != OK:
		if had_old:
			DirAccess.rename_absolute(backup, path)
		DirAccess.remove_absolute(temp)
		return false
	DirAccess.remove_absolute(backup)
	return true


## The saved dictionary, or an empty one when no file is readable. The backup is tried when the
## main file is missing or bad. JSON numbers can come back as int or float: convert with int().
static func read(path: String) -> Dictionary:
	var data: Dictionary = _read_one(path)
	if data.is_empty():
		data = _read_one(path + ".bak")
	return data


static func _write_whole(path: String, text: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	var stored: bool = file.store_string(text)
	file.close()
	return stored and file.get_error() == OK


static func _read_one(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	if text.length() > MAX_BYTES:
		return {}
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return {}
	return json.data as Dictionary
