extends Node

onready var light_bulb = preload("res://src/LightBulb/LightBulb.tscn")

func create_light_bulb(pos):
	var bulb = light_bulb.instance()
	add_child(bulb)
