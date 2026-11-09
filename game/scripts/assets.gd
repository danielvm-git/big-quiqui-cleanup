class_name Assets
extends RefCounted
## Finds art and audio by key. Keys are English, without extension: "quiqui/idle", "sfx/tap".

const ART_ROOT: String = "res://assets/art/"
const AUDIO_ROOT: String = "res://assets/audio/"


static func texture(key: String) -> Texture2D:
	for extension: String in ["png", "jpg"]:
		var path: String = "%s%s.%s" % [ART_ROOT, key, extension]
		if ResourceLoader.exists(path):
			return load(path) as Texture2D
	push_warning("missing art: %s" % key)
	return null


static func sound(key: String) -> AudioStream:
	var path: String = "%s%s.ogg" % [AUDIO_ROOT, key]
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	push_warning("missing audio: %s" % key)
	return null
