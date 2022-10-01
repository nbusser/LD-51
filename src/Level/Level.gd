extends Node

signal end_of_level
signal game_over

var level_number
var nb_coins

onready var hud = $UI/HUD
onready var map = $Map

func _ready():
	assert(
		level_number != null and nb_coins != null, "init must be called before creating Level scene"
	)
	hud.set_level_number(level_number)
	hud.set_coins(nb_coins)


func init(level_number, nb_coins):
	self.level_number = level_number
	self.nb_coins = nb_coins


func _on_Timer_timeout():
	map.add_door()
