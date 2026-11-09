# story: e02s01
extends GutTest
## The player draws its content on a 1920x1080 stage centered in any screen.


func _open(size: Vector2i, scene_id: String = "living_room") -> Player:
	var holder: Control = Control.new()
	holder.size = Vector2(size)
	add_child_autofree(holder)
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.beat_sec = 0.0
	player.scene_id = scene_id
	holder.add_child(player)
	await get_tree().process_frame
	return player


func test_the_stage_is_centered_on_every_size() -> void:
	for size: Vector2i in GeometryOracle.SIZES:
		var player: Player = await _open(size)
		var expected: Vector2 = (Vector2(size) - Vector2(1920, 1080)) * 0.5
		assert_eq(player.stage.position, expected, str(size))
		assert_eq(player.stage.size, Vector2(1920, 1080))


func test_the_living_room_passes_the_oracle_on_every_size() -> void:
	for size: Vector2i in GeometryOracle.SIZES:
		var player: Player = await _open(size)
		assert_eq(GeometryOracle.audit(player.get_parent() as Control, size), [] as Array[String], str(size))


func test_a_resize_recenters_the_stage() -> void:
	var player: Player = await _open(Vector2i(1920, 1080))
	(player.get_parent() as Control).size = Vector2(1920, 1440)
	await get_tree().process_frame
	assert_eq(player.stage.position, Vector2(0, 180))
