class_name TitleTemplate
extends StepTemplate
## t0_title: the first screen. Tap play to start. The parent area sits behind a gate and can ask for a reset.
## The TutoTOONS policy and subscription links are dropped (ADR-004): there is nothing to sell or to read.

signal reset_requested


## The play button was pressed. Done once.
func play() -> void:
	if is_done():
		return
	hit.emit()
	_finish()


func request_reset() -> void:
	reset_requested.emit()
