class_name GameSink
extends ReactionSink
## The real answer to a reaction: QuiQui's pose, a sound, a sparkle. Same-frame, throttled
## so a rub that hits every frame does not stack sounds.

signal coins_added(amount: int)

const THROTTLE_MS: int = 140

var quiqui: TextureRect = null
var host: Control = null
## Where sounds live. It must outlive the scene, or a tap that changes scene is cut off.
var audio_host: Node = null
var coins: int = 0

var _last_ms: Dictionary = {}


func play_pose(value: String) -> void:
	if quiqui != null:
		quiqui.texture = Assets.texture("quiqui/" + value)


func play_sfx(value: String) -> void:
	if _throttled("sfx:" + value):
		return
	_play(Assets.sound("sfx/" + value))


func play_voice(value: String) -> void:
	_play(Assets.sound("voice/" + value))


func play_fx(value: String) -> void:
	if host == null or quiqui == null or _throttled("fx:" + value):
		return
	var fx: TextureRect = TextureRect.new()
	fx.texture = Assets.texture("effects/" + value)
	fx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fx.size = Vector2(160, 160)
	fx.position = quiqui.position + Vector2(randf_range(0, quiqui.size.x), randf_range(0, 120))
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(fx)
	var tween: Tween = fx.create_tween().set_parallel(true)
	tween.tween_property(fx, "position:y", fx.position.y - 120.0, 0.6)
	tween.tween_property(fx, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(fx.queue_free)


func play_music(key: String) -> void:
	if key.is_empty():
		return
	var stream: AudioStream = Assets.sound(key)
	if host == null or stream == null:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -8.0
	host.add_child(player)
	player.play()


func add_coins(amount: int) -> void:
	coins += amount
	coins_added.emit(amount)


func _throttled(key: String) -> bool:
	var now: int = Time.get_ticks_msec()
	if now - int(_last_ms.get(key, -THROTTLE_MS)) < THROTTLE_MS:
		return true
	_last_ms[key] = now
	return false


func _play(stream: AudioStream) -> void:
	var parent: Node = audio_host if audio_host != null else host
	if parent == null or stream == null:
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	parent.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
