extends CanvasLayer

@export var arena_timer_manager: Node

@onready var label = %Label


func _process(delta):
	if arena_timer_manager == null:
		return
	
	var time_elapsed = arena_timer_manager.get_time_elapsed()
	label.text = format_seconds_to_string(time_elapsed)


func format_seconds_to_string(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return ("%02d:" % floor(minutes)) + ("%02d" % floor(remaining_seconds))
