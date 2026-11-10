class_name SaveFile
extends RefCounted
## One JSON dictionary on disk. A write goes to "<path>.tmp" first and is then renamed over the
## target, so a crash leaves the old file whole. The path is an argument: the core knows no game path.


static func write(path: String, data: Dictionary) -> bool:
	var temp: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	if DirAccess.rename_absolute(temp, path) == OK:
		return true
	# Some platforms refuse to rename over an existing file.
	DirAccess.remove_absolute(path)
	return DirAccess.rename_absolute(temp, path) == OK


## The saved dictionary, or an empty one when the file is missing, unreadable or not a dictionary.
## JSON numbers come back as floats.
static func read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	if json.data is Dictionary:
		return json.data as Dictionary
	return {}
