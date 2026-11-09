extends Control
## Boot: opens the player. With no map yet (slice S2), Home restarts the living room.


func _ready() -> void:
	_open_player()


func _open_player() -> void:
	var player: Player = (load("res://scenes/player.tscn") as PackedScene).instantiate() as Player
	player.left.connect(_on_left.bind(player))
	add_child(player)


func _on_left(_target: String, player: Player) -> void:
	player.queue_free()
	_open_player.call_deferred()
