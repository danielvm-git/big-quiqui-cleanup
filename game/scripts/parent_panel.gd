class_name ParentPanel
extends Control
## The parent area. It has words, which ADR-003 allows here (never during play). One setting: reset progress,
## which asks twice. Closing disarms it.

signal reset_confirmed
signal closed

const ARM_SEC: float = 5.0

var reset_button: Button = Button.new()
var close_button: Button = Button.new()

var _armed: bool = false
var _disarm: Tween = null
var _note: Label = Label.new()


func _init() -> void:
	visible = false
	z_index = 10
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_add_dim()
	var box: VBoxContainer = VBoxContainer.new()
	box.position = Vector2(560, 300)
	box.size = Vector2(800, 480)
	box.add_theme_constant_override("separation", 40)
	add_child(box)
	_note.text = tr("Ad-free and offline. Nothing leaves this device.")
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.add_theme_font_size_override("font_size", 44)
	box.add_child(_note)
	_style(reset_button, tr("Reset progress"), box)
	_style(close_button, tr("Close"), box)
	reset_button.pressed.connect(_on_reset)
	close_button.pressed.connect(close)


func _add_dim() -> void:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.2, 0.12, 0.08, 0.7)
	dim.position = Vector2(-3000, -3000)
	dim.size = Vector2(8000, 8000)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)


func note_text() -> String:
	return _note.text


func is_armed() -> bool:
	return _armed


func open() -> void:
	visible = true


func close() -> void:
	disarm()
	visible = false
	closed.emit()


## Back to "Reset progress". It also happens by itself a few seconds after the first tap.
func disarm() -> void:
	_armed = false
	reset_button.text = tr("Reset progress")
	if _disarm != null:
		_disarm.kill()
		_disarm = null


## The second tap resets and closes the panel: the panel going away is the answer.
func _on_reset() -> void:
	if not _armed:
		_armed = true
		reset_button.text = tr("Tap again to reset")
		_disarm = create_tween()
		_disarm.tween_callback(disarm).set_delay(ARM_SEC)
		return
	disarm()
	reset_confirmed.emit()
	close()


func _style(button: Button, text: String, parent: Control) -> void:
	button.text = text
	button.custom_minimum_size = Vector2(800, 130)
	button.add_theme_font_size_override("font_size", 48)
	parent.add_child(button)
