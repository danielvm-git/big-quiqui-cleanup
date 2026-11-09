# story: e01s03
extends GutTest
## The runner turns a Reaction list into ordered sink calls and reports what it could not run.


class RecordingSink:
	extends ReactionSink
	var calls: Array[String] = []

	func play_pose(value: String) -> void:
		calls.append("pose:" + value)

	func play_sfx(value: String) -> void:
		calls.append("sfx:" + value)

	func play_voice(value: String) -> void:
		calls.append("voice:" + value)

	func play_fx(value: String) -> void:
		calls.append("fx:" + value)

	func swap_texture(value: String) -> void:
		calls.append("swap:" + value)

	func add_coins(amount: int) -> void:
		calls.append("coins:%d" % amount)

	func wait_sec(seconds: float) -> void:
		calls.append("wait:%s" % seconds)


func _reaction(kind: String, value: String) -> Reaction:
	var reaction: Reaction = Reaction.new()
	reaction.kind = kind
	reaction.value = value
	return reaction


func test_runs_reactions_in_order() -> void:
	var sink: RecordingSink = RecordingSink.new()
	var list: Array[Reaction] = [_reaction("sfx", "pop"), _reaction("pose", "happy")]
	ReactionRunner.run(list, sink)
	assert_eq(sink.calls, ["sfx:pop", "pose:happy"] as Array[String])


func test_every_kind_reaches_the_sink() -> void:
	var sink: RecordingSink = RecordingSink.new()
	var list: Array[Reaction] = [
		_reaction("pose", "a"),
		_reaction("sfx", "b"),
		_reaction("voice", "c"),
		_reaction("fx", "d"),
		_reaction("swap", "e"),
		_reaction("coins", "3"),
		_reaction("wait", "0.5"),
	]
	ReactionRunner.run(list, sink)
	assert_eq(sink.calls.size(), 7)
	assert_eq(sink.calls[5], "coins:3")
	assert_eq(sink.calls[6], "wait:0.5")


func test_unknown_kind_is_reported_and_the_rest_still_runs() -> void:
	var sink: RecordingSink = RecordingSink.new()
	var list: Array[Reaction] = [_reaction("explode", "x"), _reaction("sfx", "pop")]
	var skipped: int = ReactionRunner.run(list, sink)
	assert_eq(skipped, 1)
	assert_eq(sink.calls, ["sfx:pop"] as Array[String])


func test_empty_list_does_nothing() -> void:
	var sink: RecordingSink = RecordingSink.new()
	assert_eq(ReactionRunner.run([] as Array[Reaction], sink), 0)
	assert_eq(sink.calls.size(), 0)
