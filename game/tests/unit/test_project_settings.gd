# story: e05s01
extends GutTest
## The project is set up for a handheld device: landscape, an icon the App Store accepts, no version baked in.

const SENSOR_LANDSCAPE: int = 4


func test_the_game_runs_in_landscape_either_way_up() -> void:
	assert_eq(int(ProjectSettings.get_setting("display/window/handheld/orientation")), SENSOR_LANDSCAPE)


func test_the_icon_is_set_square_large_and_opaque() -> void:
	var path: String = str(ProjectSettings.get_setting("application/config/icon"))
	assert_true(path.begins_with("res://"), "icon path is set")
	var texture: Texture2D = load(path) as Texture2D
	assert_not_null(texture)
	var image: Image = texture.get_image()
	assert_eq(image.get_width(), image.get_height(), "square")
	assert_gte(image.get_width(), 1024)
	assert_eq(image.detect_alpha(), Image.ALPHA_NONE, "the App Store rejects an icon with transparency")


func test_the_version_is_not_baked_in() -> void:
	assert_eq(str(ProjectSettings.get_setting("application/config/version")), "0.0.0")


func test_the_stage_is_full_hd_and_stretches_without_distortion() -> void:
	assert_eq(int(ProjectSettings.get_setting("display/window/size/viewport_width")), 1920)
	assert_eq(int(ProjectSettings.get_setting("display/window/size/viewport_height")), 1080)
	assert_eq(str(ProjectSettings.get_setting("display/window/stretch/aspect")), "expand")


func test_no_game_script_uses_a_network_api() -> void:
	var banned: Array[String] = [
		"HTTPRequest", "HTTPClient", "WebSocketPeer", "TCPServer", "StreamPeerTCP", "UDPServer"
	]
	for dir: String in ["res://scripts/", "res://addons/quiqui_core/"]:
		for file: String in _gd_files(dir):
			var text: String = FileAccess.get_file_as_string(file)
			for word: String in banned:
				assert_false(text.contains(word), "%s uses %s" % [file, word])


func _gd_files(dir: String) -> Array[String]:
	var found: Array[String] = []
	for entry: String in DirAccess.get_files_at(dir):
		if entry.ends_with(".gd"):
			found.append(dir + entry)
	for sub: String in DirAccess.get_directories_at(dir):
		found.append_array(_gd_files(dir + sub + "/"))
	return found
