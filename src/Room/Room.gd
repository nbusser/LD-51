signal declare_neighbour(neighbour)

extends Node2D

onready var tilemap = $"../../TileMap"
onready var doors_manager = $"../../Doors"
onready var lights = $LightBulbs
onready var patrol_path = $RoomArea/RoomShape/PatrolPath

var doors_positions
var contained_characters = []

var _patrol_points
var _patrol_cells = []

func _ready():
	if $RoomArea/RoomShape.shape == null:
		print('ERROR: missing room shape for', self)
	
	patrol_path.visible = false
	
	_patrol_points = patrol_path.get_points()
	for point in _patrol_points:
		_patrol_cells.append(tilemap.world_to_map(point))

	if len(_patrol_points) == 0:
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

func contains_character(target_character):
	for character in contained_characters:
		if character == target_character:
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

func get_patrol_points(world_coordinated=false):
	if world_coordinated:
		return _patrol_points
	else:
		return _patrol_cells

func get_next_patrol_index(i):
	return (i + 1) % len(_patrol_points)
