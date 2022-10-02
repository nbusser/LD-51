extends Node

onready var hud = $UI/HUD
onready var map = get_node("Map")
onready var player = $Map/Navigation2D/Characters/Player
onready var doors_manager = $Map/Navigation2D/Doors

var level_names = ["Alpha Condor", "Busser Force One"]

var difficulty

func init(level_number):
	difficulty = level_number
	yield(get_node("UI/HUD"), "ready")
	get_node("UI/HUD").set_level_decoration(level_number, level_names[level_number])

func _on_Timer_timeout():
	trigger_calamity()

enum Calamities {
	LIGHTS_OFF
	ROOM_ALERT
	CLOSE_DOOR
	SPAWN_MONSTER
}

func trigger_calamity():
	var calamity = randi()%len(Calamities)
	calamity = Calamities.ROOM_ALERT
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
