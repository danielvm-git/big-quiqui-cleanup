class_name MapView
extends Control
## The view of t25_map: a card per room. A cloud marks a dirty room, a sparkle a clean one.

signal touched

var template: MapTemplate = MapTemplate.new()

var _pulse: Tween = null


func configure(params: Dictionary) -> void:
	template.setup(params)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for room: Variant in params["rooms"] as Array:
		_add_card(room as Dictionary)
	refresh()


func refresh() -> void:
	for child: Node in get_children():
		var badge: TextureRect = child.get_node("badge") as TextureRect
		var key: String = "effects/sparkle" if template.is_clean(str(child.name)) else "effects/foam"
		badge.texture = Assets.texture(key)


func set_hint(on: bool) -> void:
	if _pulse != null:
		_pulse.kill()
	var dirty: Control = _first_dirty()
	if not on or dirty == null:
		return
	dirty.pivot_offset = dirty.size * 0.5
	_pulse = dirty.create_tween().set_loops()
	_pulse.tween_property(dirty, "scale", Vector2(1.06, 1.06), 0.5)
	_pulse.tween_property(dirty, "scale", Vector2.ONE, 0.5)


func _first_dirty() -> Control:
	for child: Node in get_children():
		if not template.is_clean(str(child.name)):
			return child as Control
	return null


func _add_card(room: Dictionary) -> void:
	var id: String = str(room["id"])
	var rect: Rect2 = room["rect"] as Rect2
	var card: TextureRect = TextureRect.new()
	card.name = id
	card.texture = Assets.texture(str(room["art"]))
	card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	card.clip_contents = true
	card.position = rect.position
	card.size = rect.size
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.add_to_group("hit_target")
	card.gui_input.connect(_on_card_input.bind(id))
	card.add_child(_make_badge(rect.size))
	add_child(card)


func _make_badge(card_size: Vector2) -> TextureRect:
	var badge: TextureRect = TextureRect.new()
	badge.name = "badge"
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.size = Vector2(150, 150)
	badge.position = Vector2(card_size.x - 160.0, 10.0)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return badge


func _on_card_input(event: InputEvent, id: String) -> void:
	if StepTemplate.is_echo(event):
		return
	touched.emit()
	if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		template.choose_room(id)
