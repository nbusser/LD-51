signal declare_neighbour(neighbour)

extends Node2D

onready var tilemap = $"../../TileMap"
onready var doors_manager = $"../../Doors"
onready var lights = $LightBulbs
onready var patrol_path = $RoomArea/RoomShape/PatrolPath

var doors_positions
var contained_characters = []

var patrol_points

func _ready():
	if $RoomArea/RoomShape.shape == null:
		print('ERROR: missing room shape for', self)
	
	patrol_path.visible = false
	
	patrol_points = patrol_path.get_points()
	for i in range(len(patrol_points)):
		patrol_points[i] = tilemap.world_to_map(patrol_points[i])

	if len(patrol_points) == 0:
		print('ERROR: missing patrol for', self)

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
