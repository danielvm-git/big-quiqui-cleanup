extends SceneTree
## In-engine screenshots of the whole house (the suite cannot see composition).
## godot --path game -s res://tools/capture_scene.gd -- <out_prefix> [width height]
## Writes <prefix>_map.png, then <prefix>_<room>_start.png and _outro.png per room, then _map_clean.png.

const ROOMS: Array[String] = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]

var _boot: Boot = null
var _prefix: String = "/tmp/qq_capture/house"


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_prefix = args[0]
	_boot = (load("res://scenes/boot.tscn") as PackedScene).instantiate() as Boot
	_boot.beat_sec = 0.0
	root.add_child(_boot)
	await _shot("map")
	for room: String in ROOMS:
		(_boot.player.template() as MapTemplate).choose_room(room)
		await _shot(room + "_start")
		await _half(room)
		_finish()
		await _shot(room + "_outro")
		_boot.player.outro_button.pressed.emit()
		await process_frame
	await _shot("map_clean")
	quit(0)


func _shot(name: String) -> void:
	for frame: int in 20:
		await process_frame
	var path: String = "%s_%s.png" % [_prefix, name]
	root.get_texture().get_image().save_png(path)
	print("captured ", path)


## Half way through the first step, so the dirt and a carried or touched item show.
func _half(room: String) -> void:
	var template: StepTemplate = _boot.player.template()
	var params: Dictionary = _boot.player.scene_player.current_step().params
	if template is EraseTemplate:
		var rect: Rect2 = params["layer_rect"] as Rect2
		var erase: EraseTemplate = template as EraseTemplate
		erase.rub_begin(rect.position + Vector2(0, 60))
		erase.rub_to(rect.position + Vector2(rect.size.x * 0.6, 60))
	elif template is DragSnapTemplate:
		var drag: DragSnapTemplate = template as DragSnapTemplate
		var first: String = drag.remaining()[0]
		drag.pick(first)
		drag.drop((params["target_rect"] as Rect2).get_center())
	elif template is TouchEachTemplate:
		(template as TouchEachTemplate).touch((template as TouchEachTemplate).remaining()[0])
	await _shot(room + "_half")


func _finish() -> void:
	var guard: int = 0
	while _boot.player.scene_player.state() == ScenePlayer.STEP and guard < 10:
		var step: StepDef = _boot.player.scene_player.current_step()
		StepSolver.solve(_boot.player.template(), step.params)
		guard += 1
