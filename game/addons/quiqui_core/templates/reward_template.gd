class_name RewardTemplate
extends TouchEachTemplate
## t32_reward: collect every star once. Done when none is left. Nothing can be missed or lost.
## Params: stars (how many, 1 to MAX_STARS).

const MAX_STARS: int = 6


static func star_id(index: int) -> String:
	return "star_%d" % index


func setup(params: Dictionary) -> void:
	var count: int = clampi(int(params.get("stars", 1)), 1, MAX_STARS)
	var ids: Array = []
	for index: int in count:
		ids.append(star_id(index))
	super.setup({"targets": ids})
