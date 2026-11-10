class_name Assets
extends RefCounted
## Finds art and audio by key. Keys are English, without extension: "quiqui/idle", "sfx/tap".

const ART_ROOT: String = "res://assets/art/"
const AUDIO_ROOT: String = "res://assets/audio/"

## Voice lives in audio/voice/<locale>/<file>.ogg. The first locale is pt_BR (recorded by the family).
static var voice_root: String = AUDIO_ROOT + "voice/"
static var locale: String = "pt_BR"


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


## "vo.living_room.intro" is the file "living_room_intro.ogg" in the locale folder.
static func voice_path(key: String) -> String:
	return "%s%s/%s.ogg" % [voice_root, locale, key.trim_prefix("vo.").replace(".", "_")]


## A recorded line, or null. A missing line is silent: no recordings exist yet, and the
## game must still run (scripts/check_voice.sh lists what is missing).
static func voice(key: String) -> AudioStream:
	if key.is_empty():
		return null
	var path: String = voice_path(key)
	if not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream
