class_name DirtView
extends Control
## The view of t23_erase: a layer of dust over the floor and a sponge under the finger.

signal touched

var template: EraseTemplate = EraseTemplate.new()

var _rect: Rect2 = Rect2()
var _cell: float = 20.0
var _sponge: TextureRect = null
var _pulse: Tween = null


func configure(params: Dictionary) -> void:
	template.setup(params)
	_rect = params["layer_rect"] as Rect2
	_cell = float(params.get("cell", 20.0))
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	template.hit.connect(queue_redraw)
	_sponge = TextureRect.new()
	_sponge.texture = Assets.texture("items/sponge")
	_sponge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sponge.size = Vector2(200, 200)
	_sponge.visible = false
	_sponge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sponge)


func set_hint(on: bool) -> void:
	if _pulse != null:
		_pulse.kill()
	modulate.a = 1.0
	if on:
		_pulse = create_tween().set_loops()
		_pulse.tween_property(self, "modulate:a", 0.55, 0.5)
		_pulse.tween_property(self, "modulate:a", 1.0, 0.5)


func _gui_input(event: InputEvent) -> void:
	if StepTemplate.is_echo(event):
		return
	touched.emit()
	template.handle_input(event)
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		_sponge.visible = touch.pressed
		_sponge.position = touch.position - _sponge.size * 0.5
	elif event is InputEventScreenDrag:
		_sponge.position = (event as InputEventScreenDrag).position - _sponge.size * 0.5


func _draw() -> void:
	var grid: Vector2i = template.grid_size()
	for row: int in grid.y:
		for col: int in grid.x:
			if not template.is_cell_cleared(col, row):
				var center: Vector2 = _rect.position + (Vector2(col, row) + Vector2(0.5, 0.5)) * _cell
				draw_circle(center, _cell * _blob(col, row), dust_color(col, row))


func _blob(col: int, row: int) -> float:
	return 0.7 + 0.35 * float((col * 31 + row * 17) % 7) / 7.0


## The first dirt level is heavy, the next ones lighter.
func dust_strength() -> float:
	var total: int = template.level_count()
	return float(total - template.level) / float(total)


func dust_color(col: int, row: int) -> Color:
	var shade: float = float((col * 11 + row * 23) % 9) / 9.0
	var alpha: float = (0.32 + 0.2 * shade) * dust_strength()
	return Color(0.5 - 0.12 * shade, 0.4 - 0.1 * shade, 0.3 - 0.05 * shade, alpha)
