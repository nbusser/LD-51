extends Node

onready var hud = $UI/HUD
onready var map = get_node("Map")
onready var player = $Map/Navigation2D/Characters/Player
onready var doors_manager = $Map/Navigation2D/Doors

onready var pulse = $"%VisualPulse"
onready var timer = $"%Timer"
onready var music_timer = $"%MusicTimer"

var level_names = ["Alpha Condor", "Busser Force One"]

var difficulty

func init(level_number):
	difficulty = level_number
	yield(get_node("UI/HUD"), "ready")
	get_node("UI/HUD").set_level_decoration(level_number, level_names[level_number])

func _ready():
	pulse.material.set_shader_param("time", 0.0)
	pulse.material.set_shader_param("intensity", 0.0)
	pulse.material.set_shader_param("enabled", false)

	# sync timer with music
	var current_player: AudioStreamPlayer = get_viewport().get_parent().get_parent().current_player
	var music_diff = 1.0 - fmod(current_player.get_playback_position(), 1.0)
	music_timer.start(music_diff)

func _process(delta):
	pulse.material.set_shader_param("time", timer.wait_time - timer.time_left)
	pulse.material.set_shader_param("intensity", 1.0 - timer.time_left / timer.wait_time)

func _on_Timer_timeout():
	pulse.material.set_shader_param("enabled", true)
	trigger_calamity()

enum Calamities {
	LIGHTS_OFF
	ROOM_ALERT
	CLOSE_DOOR
	SPAWN_MONSTER
}

func trigger_calamity():
	var calamity = randi()%len(Calamities)
	if calamity == Calamities.LIGHTS_OFF:
		print('light')
		map.lights_off()
	elif calamity == Calamities.ROOM_ALERT:
		print('room alert')
		if randi()%2:
			map.room_alert()
		else:
			map.neighbour_room_alert()
	elif calamity == Calamities.CLOSE_DOOR:
		print('door')
		map.close_doors()
	elif calamity == Calamities.SPAWN_MONSTER:
		map.spawn_monster()
		print('spawn monster')

func _on_MusicTimer_timeout():
	timer.start()
