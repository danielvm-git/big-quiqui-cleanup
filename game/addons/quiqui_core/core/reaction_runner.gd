class_name ReactionRunner
extends RefCounted
## Runs a Reaction list in order through a sink. Returns how many reactions it skipped.


static func run(reactions: Array[Reaction], sink: ReactionSink) -> int:
	var skipped: int = 0
	for reaction: Reaction in reactions:
		if not _dispatch(reaction, sink):
			skipped += 1
	return skipped


static func _dispatch(reaction: Reaction, sink: ReactionSink) -> bool:
	match reaction.kind:
		"pose":
			sink.play_pose(reaction.value)
		"sfx":
			sink.play_sfx(reaction.value)
		"voice":
			sink.play_voice(reaction.value)
		"fx":
			sink.play_fx(reaction.value)
		"swap":
			sink.swap_texture(reaction.value)
		"coins":
			sink.add_coins(reaction.value.to_int())
		"wait":
			sink.wait_sec(reaction.value.to_float())
		_:
			return false
	return true
