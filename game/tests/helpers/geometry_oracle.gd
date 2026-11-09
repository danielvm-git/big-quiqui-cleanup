# story: e02s01
class_name GeometryOracle
extends RefCounted
## Layout audit for one viewport size. Rewritten for this repo (BACKLOG planned port).
## Rules: the root is the canvas, every node in group "background" covers it, and every
## visible node in group "hit_target" is at least 120x120 and fully inside it.

const MIN_HIT_SIZE: Vector2 = Vector2(120.0, 120.0)
const HIT_GROUP: String = "hit_target"
const BACKGROUND_GROUP: String = "background"
const TOLERANCE: float = 1.0
const SIZES: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1920, 1440),
	Vector2i(2048, 1536),
	Vector2i(2400, 1080),
]


static func audit(root: Control, viewport: Vector2i) -> Array[String]:
	var findings: Array[String] = []
	var canvas: Rect2 = Rect2(Vector2.ZERO, Vector2(viewport))
	if root.get_global_rect().size.distance_to(canvas.size) > TOLERANCE:
		findings.append("root is %s, viewport is %s" % [root.get_global_rect().size, canvas.size])
	_walk(root, canvas, findings)
	return findings


static func _walk(node: Node, canvas: Rect2, findings: Array[String]) -> void:
	if node is Control and (node as Control).is_visible_in_tree():
		var control: Control = node as Control
		if control.is_in_group(BACKGROUND_GROUP):
			_check_background(control, canvas, findings)
		if control.is_in_group(HIT_GROUP):
			_check_hit(control, canvas, findings)
	for child: Node in node.get_children():
		_walk(child, canvas, findings)


static func _check_background(control: Control, canvas: Rect2, findings: Array[String]) -> void:
	if not control.get_global_rect().grow(TOLERANCE).encloses(canvas):
		findings.append("background %s does not cover %s" % [control.name, canvas.size])


static func _check_hit(control: Control, canvas: Rect2, findings: Array[String]) -> void:
	var rect: Rect2 = control.get_global_rect()
	if rect.size.x < MIN_HIT_SIZE.x or rect.size.y < MIN_HIT_SIZE.y:
		findings.append("hit target %s is %s, minimum %s" % [control.name, rect.size, MIN_HIT_SIZE])
	if not canvas.grow(TOLERANCE).encloses(rect):
		findings.append("hit target %s at %s leaves the screen" % [control.name, rect])
