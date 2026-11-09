class_name ReactionSink
extends RefCounted
## What a reaction can ask for. The game provides the real one; tests provide a recorder.


func play_pose(_value: String) -> void:
	pass


func play_sfx(_value: String) -> void:
	pass


func play_voice(_value: String) -> void:
	pass


func play_fx(_value: String) -> void:
	pass


func swap_texture(_value: String) -> void:
	pass


func add_coins(_amount: int) -> void:
	pass


func wait_sec(_seconds: float) -> void:
	pass
