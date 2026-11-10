extends SceneTree
## In-engine screenshots of the whole house (the suite cannot see composition).
## godot --path game -s res://tools/capture_scene.gd -- <out_prefix> [width height]
## Writes <prefix>_map.png, then <prefix>_<room>_start.png, _half.png and _outro.png per room, the reward
## (_reward_start, _reward_half, _reward_done after the first room), then _map_clean.png.
## It saves to a throwaway file, never to the real save.

const ROOMS: Array[String] = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]
const SAVE: String = "user://capture_progress.json"

var _boot: Boot = null
var _prefix: String = "/tmp/qq_capture/house"


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_prefix = args[0]
	_boot = (load("res://scenes/boot.tscn") as PackedScene).instantiate() as Boot
	_boot.beat_sec = 0.0
	_boot.save_path = SAVE
	DirAccess.remove_absolute(SAVE)
	root.add_child(_boot)
	await _title()
	await _shot("map")
	for room: String in ROOMS:
		await _room(room)
	await _shot("map_clean")
	DirAccess.remove_absolute(SAVE)
	quit(0)


## The title, then the parent area over it, then play.
func _title() -> void:
	await _shot("title")
	var title: TitleView = _boot.player.stage.get_child(0) as TitleView
	title.panel.open()
	await _shot("title_parent")
	title.panel.close()
	(_boot.player.template() as TitleTemplate).play()
	await process_frame
	await process_frame


func _room(room: String) -> void:
	(_boot.player.template() as MapTemplate).choose_room(room)
	await _shot(room + "_start")
	await _half(room)
	await _reveal_shot(room)
	_finish()
	await _shot(room + "_outro")
	_boot.player.outro_button.pressed.emit()
	await process_frame
	await _reward(room == ROOMS[0])


## The last step is the reveal: one shot untouched, one with a band rubbed away.
func _reveal_shot(room: String) -> void:
	var guard: int = 0
	while not _boot.player.template() is RevealTemplate and guard < 10:
		StepSolver.solve(_boot.player.template(), _boot.player.scene_player.current_step().params)
		guard += 1
	await _shot(room + "_reveal_start")
	var erase: EraseTemplate = _boot.player.template() as EraseTemplate
	for y: int in range(300, 700, 100):
		erase.rub_begin(Vector2(200, y))
		erase.rub_to(Vector2(1100, y))
	erase.rub_end()
	await _shot(room + "_reveal_half")


## The reward scene after a room. Only the first room gets screenshots; the rest just pass through.
func _reward(shoot: bool) -> void:
	if shoot:
		await _shot("reward_start")
		_tap_star("star_0")
		await _shot("reward_half")
	_finish()
	if shoot:
		await _shot("reward_done")
	_boot.player.outro_button.pressed.emit()
	await process_frame


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


## A real touch on the star's node, so the view animates it (the template alone would not).
func _tap_star(id: String) -> void:
	for node: Node in _boot.get_tree().get_nodes_in_group("hit_target"):
		if node.name == id:
			var touch: InputEventScreenTouch = InputEventScreenTouch.new()
			touch.pressed = true
			touch.position = Vector2(10, 10)
			(node as Control).gui_input.emit(touch)


func _finish() -> void:
	var guard: int = 0
	while _boot.player.scene_player.state() == ScenePlayer.STEP and guard < 10:
		var step: StepDef = _boot.player.scene_player.current_step()
		StepSolver.solve(_boot.player.template(), step.params)
		guard += 1
