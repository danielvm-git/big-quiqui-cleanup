class_name Reaction
extends Resource
## One answer to a gesture: a pose, a sound, a voice line, an effect and so on.

const KINDS: Array[String] = ["pose", "sfx", "voice", "fx", "swap", "coins", "wait"]

@export var kind: String = ""
@export var value: String = ""


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not KINDS.has(kind):
		errors.append("reaction kind '%s' is not one of %s" % [kind, KINDS])
	return errors
