extends Interactible

signal light_alert_stopped

@export var state = Globals.LightingState.ON

@onready var enemy_blind_area = $EnemyBlindZone

func _init():
	super(Globals.Interactibles.LIGHT)
	pass

func _ready():
	change_state(state, false)
	
func _change_color(new_color, length=0.5):
	$Tween.interpolate_property(
		$PointLight2D, "color",
		$PointLight2D.color, new_color,
		length, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	$Tween.start()

func change_state(new_state, play_sound=true):
	enemy_blind_area.monitorable = new_state == Globals.LightingState.ON
	
	if new_state == Globals.LightingState.OFF:
		$PointLight2D.color.a = 0
		$BlinkingOffTimer.start()
		
		if play_sound:
			$SoundFx/BlackoutSound.play_sound()
	else:
		if new_state == Globals.LightingState.ON:
			_change_color(Color(1, 1, 1, 1))
			if play_sound:
				$SoundFx/LightOnSound.play_sound()
		else:
			_change_color(Color(1, 0, 0, 1))
	
	state = new_state


func _on_Tween_tween_completed(_object, _key):
	if state == Globals.LightingState.ALERT:
		var current_alpha = $PointLight2D.color.a
		_change_color(Color(1, 0, 0, 1-current_alpha), 0.7)

func _is_blinking():
	return $BlinkingOffTimer.time_left > 0 or $LastBlink.time_left > 0

func _on_BlinkingOffTimer_timeout():
	$PointLight2D.color.a = 1
	$LastBlink.wait_time = 0.3
	$LastBlink.start()

func _on_LastBlink_timeout():
	$PointLight2D.color = Color(0, 0, 0, 0)
	$EnemyBlindZone/EnemyBlindZone.disabled = true

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
