signal declare_neighbour(neighbour)
signal alert_stopped

extends Node2D

onready var map = $"../../../../"
onready var tilemap = $"../../WalkableMap"
onready var doors_manager = $"../../Doors"
onready var lights = $LightBulbs
onready var patrol_path = $PatrolPath

var doors_positions
var contained_characters = []

var _patrol_points
var _patrol_cells = []

func _check_patrol_accessible():
	var first_point = _patrol_points[0]
	var i = 1
	while i < len(_patrol_points):
		var second_point = _patrol_points[i]
		var path = map.get_path_to_target(first_point, second_point)
		if map.get_path_to_target(first_point, second_point) == null:
			return false
		first_point = second_point
		i += 1
	return true

func _ready():
	for light_bulb in $LightBulbs.get_children():
		light_bulb.connect("light_alert_stopped", self, "_alert_update")
	
	if $RoomArea/RoomShape.shape == null:
		print('ERROR: missing room shape for ', self)
	
	patrol_path.visible = false
	
	_patrol_points = patrol_path.get_points()
	for i in range(len(_patrol_points)):
		_patrol_points[i] += global_position #+ Vector2(0, -16)
		_patrol_cells.append(tilemap.world_to_map(_patrol_points[i]))

	if len(_patrol_points) == 0:
		print('ERROR: missing patrol for ', self)
	else:
		yield(map, "ready")
		if not _check_patrol_accessible():
			print('ERROR: patrol is not accessible ', self)

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

func _alert_update():
	if $AlertTimer.time_left > 0:
		if not is_in_alert():
			emit_signal("alert_stopped")

func is_in_alert():
	for light in lights.get_children():
		if light.state == Globals.LightingState.ALERT:
			return true
	return false

func trigger_alert():
	for light in lights.get_children():
		light.change_state(Globals.LightingState.ALERT)
	$AlertTimer.start()

func get_patrol_points(world_coordinated=false):
	if world_coordinated:
		return _patrol_points
	else:
		return _patrol_cells

func get_next_patrol_index(i):
	return (i + 1) % len(_patrol_points)

func _on_AlertTimer_timeout():
	if is_in_alert():
		for light in lights.get_children():
			light.change_state(Globals.LightingState.ON)
			emit_signal("alert_stopped")
