# story: e04s01
extends GutTest
## Voice is referenced by key and chosen by locale (ADR-003). A missing file is silent, never a crash.

const FIXTURES: String = "res://tests/fixtures/voice/"

var _root: String = ""
var _locale: String = ""


func before_each() -> void:
	_root = Assets.voice_root
	_locale = Assets.locale
	Assets.voice_root = FIXTURES
	Assets.locale = "pt_BR"


func after_each() -> void:
	Assets.voice_root = _root
	Assets.locale = _locale


func test_a_key_becomes_a_file_in_the_locale_folder() -> void:
	assert_eq(Assets.voice_path("vo.living_room.intro"), FIXTURES + "pt_BR/living_room_intro.ogg")
	Assets.locale = "en"
	assert_eq(Assets.voice_path("vo.living_room.intro"), FIXTURES + "en/living_room_intro.ogg")


func test_a_recorded_line_is_found() -> void:
	assert_not_null(Assets.voice("vo.living_room.intro"))


func test_a_missing_line_is_null_not_an_error() -> void:
	assert_null(Assets.voice("vo.kitchen.intro"))
	assert_null(Assets.voice(""))


func test_a_locale_without_the_line_has_no_fallback() -> void:
	Assets.locale = "fr"
	assert_null(Assets.voice("vo.living_room.intro"))


func _players(host: Node) -> int:
	var count: int = 0
	for child: Node in host.get_children():
		if child is AudioStreamPlayer:
			count += 1
	return count


func test_the_sink_plays_a_recorded_line_and_stays_quiet_for_a_missing_one() -> void:
	var host: Node = Node.new()
	add_child_autofree(host)
	var sink: GameSink = GameSink.new()
	sink.audio_host = host
	sink.play_voice("vo.kitchen.intro")
	assert_eq(_players(host), 0)
	sink.play_voice("vo.living_room.intro")
	assert_eq(_players(host), 1)


func test_a_scene_plays_its_intro_voice_when_it_starts() -> void:
	var def: SceneDef = load("res://data/scenes/living_room.tres").duplicate() as SceneDef
	def.intro_voice = "vo.living_room.intro"
	var before: int = _players(get_tree().root)
	var player: Player = Player.new()
	player.def_override = def
	player.beat_sec = 0.0
	add_child_autofree(player)
	assert_eq(_players(get_tree().root), before + 1)


func test_every_room_names_an_intro_voice_by_key() -> void:
	for id: String in ["living_room", "kitchen", "bathroom", "bedroom", "garden"]:
		var def: SceneDef = load("res://data/scenes/%s.tres" % id) as SceneDef
		assert_eq(def.intro_voice, "vo.%s.intro" % id)
