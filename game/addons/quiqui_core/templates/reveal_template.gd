class_name RevealTemplate
extends EraseTemplate
## t34_rub_reveal: rub a "before" layer away to show what is under it. It is the erase gesture with a
## gentler default threshold, because a reveal is a reward and not a chore. Done when enough is shown.
## Params: layer_rect, cell, radius, threshold (default 0.7), levels (default 1), before (art key).


func setup(params: Dictionary) -> void:
	var merged: Dictionary = params.duplicate()
	if not merged.has("threshold"):
		merged["threshold"] = 0.7
	super.setup(merged)
