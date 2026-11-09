class_name Boot
extends Control
## Boot: owns the session (the house) and opens one scene at a time by id. Home and the
## outro come back here as `left`; an empty target means "the map".

const MAP: String = "house_map"

var house: HouseState = null
var player: Player = null
## Passed to every player. Tests set it to zero.
var beat_sec: float = 0.6


func _ready() -> void:
	var map: SceneDef = load("res://data/scenes/%s.tres" % MAP) as SceneDef
	house = HouseState.from_map(map)
	var sink: GameSink = GameSink.new()
	sink.host = self
	sink.play_music(map.music)
	_open(MAP)


func _open(scene_id: String) -> void:
	player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.scene_id = scene_id
	player.house = house
	player.beat_sec = beat_sec
	player.left.connect(_on_left.bind(player))
	player.failed.connect(_on_failed.bind(player))
	add_child(player)


func _on_left(target: String, closing: Player) -> void:
	closing.queue_free()
	_open.call_deferred(target if target != "" else MAP)


## A scene that cannot run sends the child to the map. If the map itself fails, stop: a loop helps nobody.
func _on_failed(scene_id: String, closing: Player) -> void:
	if scene_id == MAP:
		push_error("the house map cannot run")
		return
	closing.queue_free()
	_open.call_deferred(MAP)
