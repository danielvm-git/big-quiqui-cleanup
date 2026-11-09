class_name RoomMeter
extends Control
## A row of dots, one per step of the room. They fill as steps finish (no numbers, no text).

const DOT_SIZE: float = 56.0
const GAP: float = 16.0

var _filled: int = 0


func configure(total: int) -> void:
	for dot: Node in get_children():
		dot.queue_free()
	for index: int in total:
		var dot: TextureRect = TextureRect.new()
		dot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		dot.size = Vector2(DOT_SIZE, DOT_SIZE)
		dot.position = Vector2(index * (DOT_SIZE + GAP), 0)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(dot)
	size = Vector2(maxf(total * (DOT_SIZE + GAP) - GAP, 0.0), DOT_SIZE)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill(0)


func filled() -> int:
	return _filled


func fill(count: int) -> void:
	_filled = clampi(count, 0, get_child_count())
	for index: int in get_child_count():
		var key: String = "ui/dot_full" if index < _filled else "ui/dot_empty"
		(get_child(index) as TextureRect).texture = Assets.texture(key)
