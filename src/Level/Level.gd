extends Node

onready var hud = $UI/HUD
onready var map = get_node("Map")
var level_names = ["Alpha Condor", "Busser Force One"]

func init(level_number):
	yield(get_node("UI/HUD"), "ready")
	get_node("UI/HUD").set_level_decoration(level_number, level_names[level_number])

func _on_Timer_timeout():
	map.switch_random_door()
