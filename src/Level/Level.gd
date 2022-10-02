extends Node

signal end_of_level
signal game_over

var level_number

onready var hud = $UI/HUD
onready var map = $Map
var scenes = [preload("res://src/Map/Map1.tscn"), preload("res://src/Map/Map.tscn")]
var level_names = ["Alpha Condor", "Busser Force One"]

func init(level_number):
	self.level_number = level_number
	yield(get_node("UI/HUD"), "ready")
	print(level_names[level_number])
	get_node("UI/HUD").set_level_decoration(level_number, level_names[level_number])

func _on_Timer_timeout():
	map.add_door()
