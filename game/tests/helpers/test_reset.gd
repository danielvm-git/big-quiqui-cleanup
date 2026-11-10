# story: e01s01
class_name TestReset
extends RefCounted
## Test isolation: no test may read or write the production save file.
##
## The save arrives in slice S3, so the managers lookup is optional. A manager added
## later needs no change to existing tests: the reset reaches it once it exists.

const TEST_SAVE_PATH: String = "user://test_progress.json"
const PRODUCTION_SAVE_PATH: String = "user://progress.json"
const MANAGERS: Array[String] = ["ProgressManager"]


static func reset_all() -> void:
	delete_test_save()
	for manager: String in MANAGERS:
		var node: Node = manager_node(manager)
		if node == null:
			continue
		if node.has_method("set_test_mode"):
			node.call("set_test_mode", true)
		if node.has_method("reset"):
			node.call("reset")


static func delete_test_save() -> void:
	for suffix: String in ["", ".bak", ".tmp", ".corrupt"]:
		if FileAccess.file_exists(TEST_SAVE_PATH + suffix):
			DirAccess.remove_absolute(TEST_SAVE_PATH + suffix)


static func manager_node(manager: String) -> Node:
	if Engine.get_main_loop() is not SceneTree:
		return null
	return (Engine.get_main_loop() as SceneTree).root.get_node_or_null(manager)
