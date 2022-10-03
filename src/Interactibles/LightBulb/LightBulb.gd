signal light_alert_stopped

extends Interactible

export var state = Globals.LightingState.ON

onready var enemy_blind_area = $EnemyBlindZone

func _init().(Globals.Interactibles.LIGHT):
	pass

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
	enemy_blind_area.monitorable = new_state == Globals.LightingState.ON
	
	if new_state == Globals.LightingState.OFF:
		$Light2D.color.a = 0
		$BlinkingOffTimer.wait_time = 0.1
		$BlinkingOffTimer.start()
	else:
		if new_state == Globals.LightingState.ON:
			_change_color(Color(1, 1, 1, 1))
		else:
			_change_color(Color(1, 0, 0, 1))
	
	state = new_state


func _on_Tween_tween_completed(_object, _key):
	if state == Globals.LightingState.ALERT:
		var current_alpha = $Light2D.color.a
		_change_color(Color(1, 0, 0, 1-current_alpha), 0.7)

func _is_blinking():
	return $BlinkingOffTimer.time_left > 0 or $LastBlink.time_left > 0

func _on_BlinkingOffTimer_timeout():
	$Light2D.color.a = 1
	$LastBlink.wait_time = randf()*2
	$LastBlink.start()

func _on_LastBlink_timeout():
	$Light2D.color = Color(0, 0, 0, 0)
	$EnemyBlindZone.disabled = true

func is_interactible():
	return not _is_blinking() and state != Globals.LightingState.ON

func interact():
	if state == Globals.LightingState.OFF:
		change_state(Globals.LightingState.ON)
	elif state == Globals.LightingState.ALERT:
		change_state(Globals.LightingState.ON)
		emit_signal("light_alert_stopped")

func is_calamitable():
	return state == Globals.LightingState.ON
