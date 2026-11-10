class_name RevealView
extends DirtView
## The view of t34_rub_reveal: a hazy "before" picture over the room, rubbed away cell by cell.
## The picture is drawn like the room background (covering the whole screen), so what shows through lines up.

var _before: Texture2D = null
var _revealed: bool = false
var _params: Dictionary = {}


func _init() -> void:
	template = RevealTemplate.new()


func configure(params: Dictionary) -> void:
	_params = params
	super.configure(params)
	_before = Assets.texture(str(params.get("before", "")))
	template.completed.connect(_on_done)
	if is_inside_tree():
		_fit()


## Once in the tree the layer is the whole screen, not the stage: the room background covers the whole
## screen too, so a band of the room would otherwise show clean before any rub.
func _ready() -> void:
	_fit()
	get_viewport().size_changed.connect(_fit.call_deferred)


func before_texture() -> Texture2D:
	return _before


func is_revealed() -> bool:
	return _revealed


func _fit() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	var parent: Control = get_parent() as Control
	position = -parent.global_position if parent != null else Vector2.ZERO
	size = get_viewport_rect().size
	var wanted: Rect2 = Rect2(Vector2.ZERO, size)
	if wanted != _rect:
		var fresh: Dictionary = _params.duplicate()
		fresh["layer_rect"] = wanted
		template.setup(fresh)
		_rect = wanted
	queue_redraw()


func _on_done() -> void:
	_revealed = true
	queue_redraw()


func _draw() -> void:
	if _before == null or _revealed:
		return
	var cover: Rect2 = _cover_rect()
	var grid: Vector2i = template.grid_size()
	for row: int in grid.y:
		var start: int = -1
		for col: int in grid.x + 1:
			var dirty: bool = col < grid.x and not template.is_cell_cleared(col, row)
			if dirty and start < 0:
				start = col
			elif not dirty and start >= 0:
				_draw_run(row, start, col, cover)
				start = -1


## One draw call for a run of uncleared cells in a row.
func _draw_run(row: int, from_col: int, to_col: int, cover: Rect2) -> void:
	var origin: Vector2 = _rect.position + Vector2(from_col, row) * _cell
	var run: Rect2 = Rect2(origin, Vector2((to_col - from_col) * _cell, _cell)).intersection(cover)
	if run.size == Vector2.ZERO:
		return
	var ratio: float = cover.size.x / _before.get_size().x
	draw_texture_rect_region(_before, run, Rect2((run.position - cover.position) / ratio, run.size / ratio))


## Where the room background lies in this view's coordinates: it covers the whole viewport, centered.
func _cover_rect() -> Rect2:
	var screen: Vector2 = get_viewport_rect().size
	var tex: Vector2 = _before.get_size()
	var ratio: float = maxf(screen.x / tex.x, screen.y / tex.y)
	var covered: Vector2 = tex * ratio
	return Rect2((screen - covered) * 0.5 - global_position, covered)
