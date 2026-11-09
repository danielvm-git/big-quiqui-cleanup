class_name EraseTemplate
extends StepTemplate
## t23_erase: rub to clear a layer of dirt. Done when the cleared share reaches `threshold`.
## Params: layer_rect (Rect2), cell (float), radius (float), threshold (float), levels (int).

var level: int = 0

var _rect: Rect2 = Rect2()
var _cell: float = 20.0
var _radius: float = 30.0
var _threshold: float = 0.9
var _levels: int = 1
var _cols: int = 1
var _rows: int = 1
var _cleared: PackedByteArray = PackedByteArray()
var _cleared_count: int = 0
var _last: Vector2 = Vector2.ZERO
var _rubbing: bool = false


func setup(params: Dictionary) -> void:
	super.setup(params)
	_rect = params.get("layer_rect", Rect2(0, 0, 100, 100)) as Rect2
	_cell = float(params.get("cell", 20.0))
	_radius = float(params.get("radius", 30.0))
	_threshold = float(params.get("threshold", 0.9))
	_levels = int(params.get("levels", 1))
	level = 0
	_reset_grid()


func coverage() -> float:
	return float(_cleared_count) / float(_cols * _rows)


func grid_size() -> Vector2i:
	return Vector2i(_cols, _rows)


func is_cell_cleared(col: int, row: int) -> bool:
	return _cleared[row * _cols + col] == 1


func rub_begin(point: Vector2) -> void:
	_rubbing = true
	_last = point
	_clear_around(point)


func rub_to(point: Vector2) -> void:
	if not _rubbing:
		rub_begin(point)
		return
	var gained: int = 0
	var distance: float = _last.distance_to(point)
	var steps: int = maxi(1, ceili(distance / (_cell * 0.5)))
	for step: int in range(1, steps + 1):
		gained += _clear_around(_last.lerp(point, float(step) / float(steps)))
	_last = point
	if gained > 0:
		hit.emit()
		_check_level()


func rub_end() -> void:
	_rubbing = false


func handle_input(event: InputEvent) -> void:
	if is_echo(event):
		return
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			rub_begin(touch.position)
		else:
			rub_end()
	elif event is InputEventScreenDrag:
		rub_to((event as InputEventScreenDrag).position)
	elif event is InputEventMouseMotion and (event as InputEventMouseMotion).button_mask != 0:
		rub_to((event as InputEventMouseMotion).position)


func _reset_grid() -> void:
	_cols = maxi(1, ceili(_rect.size.x / _cell))
	_rows = maxi(1, ceili(_rect.size.y / _cell))
	_cleared = PackedByteArray()
	_cleared.resize(_cols * _rows)
	_cleared_count = 0


func _clear_around(point: Vector2) -> int:
	if not _rect.grow(_radius).has_point(point):
		return 0
	var gained: int = 0
	var first: Vector2i = _to_cell(point - Vector2(_radius, _radius))
	var last: Vector2i = _to_cell(point + Vector2(_radius, _radius))
	for row: int in range(maxi(first.y, 0), mini(last.y, _rows - 1) + 1):
		for col: int in range(maxi(first.x, 0), mini(last.x, _cols - 1) + 1):
			gained += _clear_cell(col, row, point)
	return gained


func _clear_cell(col: int, row: int, point: Vector2) -> int:
	var index: int = row * _cols + col
	if _cleared[index] == 1:
		return 0
	var center: Vector2 = _rect.position + Vector2((col + 0.5) * _cell, (row + 0.5) * _cell)
	if center.distance_to(point) > _radius:
		return 0
	_cleared[index] = 1
	_cleared_count += 1
	return 1


func _to_cell(point: Vector2) -> Vector2i:
	var local: Vector2 = point - _rect.position
	return Vector2i(floori(local.x / _cell), floori(local.y / _cell))


func _check_level() -> void:
	if coverage() < _threshold:
		return
	level += 1
	if level >= _levels:
		_finish()
	else:
		_reset_grid()
