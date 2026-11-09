# story: e02s01
extends GutTest
## The oracle must be able to fail: each rule is shown with a planted violation.

const VIEWPORT: Vector2i = Vector2i(1000, 800)


func _root() -> Control:
	var root: Control = Control.new()
	root.size = Vector2(VIEWPORT)
	add_child_autofree(root)
	return root


func _child(root: Control, group: String, rect: Rect2) -> Control:
	var control: Control = Control.new()
	control.position = rect.position
	control.size = rect.size
	control.add_to_group(group)
	root.add_child(control)
	return control


func test_a_clean_layout_has_no_findings() -> void:
	var root: Control = _root()
	_child(root, "background", Rect2(-10, -10, 1100, 900))
	_child(root, "hit_target", Rect2(50, 50, 200, 200))
	assert_eq(GeometryOracle.audit(root, VIEWPORT).size(), 0)


func test_a_wrong_root_size_is_found() -> void:
	var root: Control = _root()
	root.size = Vector2(500, 500)
	assert_gt(GeometryOracle.audit(root, VIEWPORT).size(), 0)


func test_a_background_that_does_not_cover_is_found() -> void:
	var root: Control = _root()
	_child(root, "background", Rect2(0, 0, 900, 800))
	assert_gt(GeometryOracle.audit(root, VIEWPORT).size(), 0)


func test_a_small_hit_target_is_found() -> void:
	var root: Control = _root()
	_child(root, "hit_target", Rect2(50, 50, 100, 200))
	assert_gt(GeometryOracle.audit(root, VIEWPORT).size(), 0)


func test_a_hit_target_off_screen_is_found() -> void:
	var root: Control = _root()
	_child(root, "hit_target", Rect2(900, 700, 200, 200))
	assert_gt(GeometryOracle.audit(root, VIEWPORT).size(), 0)


func test_a_hidden_hit_target_is_ignored() -> void:
	var root: Control = _root()
	var small: Control = _child(root, "hit_target", Rect2(50, 50, 10, 10))
	small.visible = false
	assert_eq(GeometryOracle.audit(root, VIEWPORT).size(), 0)
