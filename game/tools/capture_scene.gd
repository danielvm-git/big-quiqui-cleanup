extends SceneTree
## In-engine screenshots of a scene (the suite cannot see composition).
## godot --path game -s res://tools/capture_scene.gd -- <scene_id> <out_prefix>
## Writes <out_prefix>_1_dirty.png, _2_toys.png and _3_outro.png.

var _player: Player = null


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var prefix: String = args[1] if args.size() > 1 else "/tmp/qq_capture"
	_player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	_player.scene_id = args[0] if args.size() > 0 else "living_room"
	root.add_child(_player)
	await _shot(prefix + "_1_dirty.png")
	_half_wipe()
	await _shot(prefix + "_1b_half.png")
	_wipe()
	await _shot(prefix + "_2_toys.png")
	_tidy()
	await _shot(prefix + "_3_outro.png")
	quit(0)


func _shot(path: String) -> void:
	for frame: int in 20:
		await process_frame
	root.get_texture().get_image().save_png(path)
	print("captured ", path)


func _half_wipe() -> void:
	var erase: EraseTemplate = _player.template() as EraseTemplate
	for y: float in [780.0, 860.0, 940.0]:
		erase.rub_begin(Vector2(300, y))
		erase.rub_to(Vector2(1000, y))
		erase.rub_end()


func _wipe() -> void:
	var erase: EraseTemplate = _player.template() as EraseTemplate
	var y: float = 760.0
	while y <= 1080.0 and not erase.is_done():
		erase.rub_begin(Vector2(300, y))
		erase.rub_to(Vector2(1600, y))
		erase.rub_end()
		y += 40.0


func _tidy() -> void:
	var drag: DragSnapTemplate = _player.template() as DragSnapTemplate
	for id: String in drag.remaining():
		drag.pick(id)
		drag.drop(Vector2(590, 550))
