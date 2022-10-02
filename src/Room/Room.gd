signal declare_neighbour(neighbour)

extends Node2D

onready var tilemap = $"../../TileMap"
onready var doors_manager = $"../../Doors"
onready var lights = $LightBulbs

var doors_positions
var contained_characters = []

func _ready():
	if $RoomArea/RoomShape.shape == null:
		print('ERROR: missing room shape for', self)

func _on_RoomArea_area_entered(area):
	if (area.is_in_group('room')):
		emit_signal("declare_neighbour", area.get_parent())
	contained_characters.append(area.get_parent())


func _on_RoomArea_area_exited(area):
	contained_characters.erase(area.get_parent())

func contains_player():
	for character in contained_characters:
		if character.is_in_group('player'):
			return true
	return false

func is_in_alert():
	for light in lights.get_children():
		if light.state == Globals.LightingState.ALERT:
			return true
	return false

func trigger_alert():
	for light in lights.get_children():
		light.change_state(Globals.LightingState.ALERT)
