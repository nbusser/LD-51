extends Area2D

export var state = Globals.LightingState.ON

func _ready():
	change_state(state)
	
func _change_color(new_color, length=0.5):
	$Tween.interpolate_property(
		$Light2D, "color",
		$Light2D.color, new_color,
		length, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	$Tween.start()

func change_state(new_state):
	if new_state == Globals.LightingState.OFF:
		$Light2D.enabled = false
	else:
		$Light2D.enabled = true
		if new_state == Globals.LightingState.ON:
			_change_color(Color(1, 1, 1, 1))
		else:
			_change_color(Color(1, 0, 0, 1))
	
	state = new_state


func _on_Tween_tween_completed(object, key):
	if state == Globals.LightingState.ALERT:
		var current_alpha = $Light2D.color.a
		_change_color(Color(1, 0, 0, 1-current_alpha), 0.7)
