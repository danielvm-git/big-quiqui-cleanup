class_name RewardView
extends TouchView
## The view of t32_reward: stars in a row, each flies up when collected.

const SPACING: float = 300.0
const ROW_Y: float = 540.0
const STAR_ART: String = "effects/star"


func _init() -> void:
	template = RewardTemplate.new()


func configure(params: Dictionary) -> void:
	template.setup(params)
	var ids: Array[String] = template.remaining()
	var positions: Dictionary = {}
	var art: Dictionary = {}
	var left: float = 960.0 - SPACING * (ids.size() - 1) * 0.5
	for index: int in ids.size():
		positions[ids[index]] = Vector2(left + SPACING * index, ROW_Y)
		art[ids[index]] = STAR_ART
	super.configure({"stars": ids.size(), "targets": ids, "positions": positions, "art": art})


func _pop(target: TextureRect) -> void:
	var tween: Tween = target.create_tween().set_parallel(true)
	tween.tween_property(target, "position:y", target.position.y - 260.0, 0.4)
	tween.tween_property(target, "scale", Vector2(1.4, 1.4), 0.4)
	tween.tween_property(target, "modulate:a", 0.0, 0.4)
