class_name RevealView
extends DirtView
## The view of t34_rub_reveal: a hazy "before" picture over the room, rubbed away cell by cell.
## The picture is drawn like the room background (covering the whole screen), so what shows through lines up.

var _before: Texture2D = null
var _revealed: bool = false


func _init() -> void:
	template = RevealTemplate.new()


func configure(params: Dictionary) -> void:
	super.configure(params)
	_before = Assets.texture(str(params.get("before", "")))
	template.completed.connect(_on_done)


func before_texture() -> Texture2D:
	return _before


func is_revealed() -> bool:
	return _revealed


func _on_done() -> void:
	_revealed = true
	queue_redraw()


func _draw() -> void:
	if _before == null or _revealed:
		return
	var cover: Rect2 = _cover_rect()
	var scale: float = cover.size.x / _before.get_size().x
	var grid: Vector2i = template.grid_size()
	for row: int in grid.y:
		for col: int in grid.x:
			if not template.is_cell_cleared(col, row):
				_draw_cell(Rect2(_rect.position + Vector2(col, row) * _cell, Vector2(_cell, _cell)), cover, scale)


func _draw_cell(cell: Rect2, cover: Rect2, scale: float) -> void:
	var visible: Rect2 = cell.intersection(cover)
	if visible.size == Vector2.ZERO:
		return
	var source: Rect2 = Rect2((visible.position - cover.position) / scale, visible.size / scale)
	draw_texture_rect_region(_before, visible, source)


## Where the room background lies in this view's coordinates: it covers the whole viewport, centered.
func _cover_rect() -> Rect2:
	var screen: Vector2 = get_viewport_rect().size
	var tex: Vector2 = _before.get_size()
	var scale: float = maxf(screen.x / tex.x, screen.y / tex.y)
	var size_now: Vector2 = tex * scale
	return Rect2((screen - size_now) * 0.5 - global_position, size_now)
