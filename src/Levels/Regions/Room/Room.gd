signal declare_neighbour(neighbour)
signal remove_neighbour(neighbour)
signal alert_stopped

extends Node2D

onready var map = $"../../../../../"
onready var region = $"../.."
onready var tilemap = $"../../WalkableMap"
onready var doors_manager = $"../../../../../Doors"
onready var wall_deco_map = $"../../WallDecorationMap"
onready var lights = $LightBulbs
onready var patrol_path = $PatrolPath
onready var light = preload("res://src/Interactibles/LightBulb/LightBulb.tscn")

var doors_positions
var contained_characters = []

var _patrol_points
var _patrol_cells = []

func gb(x):
	return region.to_global(x)

func _check_patrol_accessible():
	var first_point = gb(_patrol_points[0])
	var i = 1
	while i < len(_patrol_points):
		var second_point = gb(_patrol_points[i])
		if region.get_path_to_target(first_point, second_point) == null:
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
		_patrol_cells.append(tilemap.world_to_map(_patrol_points[i]))
	
	if len(_patrol_points) == 0:
		print('ERROR: missing patrol for ', self)
	else:
		yield(map, "ready")
		if not _check_patrol_accessible():
			print('ERROR: patrol is not accessible ', self)

	_initialize_lights()

func _is_in_room(cell):
	var offset = $RoomArea/RoomShape.global_position
	var shape_extent = $RoomArea/RoomShape.shape.extents
	var upper_left_cell = tilemap.world_to_map(offset - shape_extent)
	var bottom_right_cell = tilemap.world_to_map(offset + shape_extent)
	
	return (
		cell.x >= upper_left_cell.x 
		and cell.x <= bottom_right_cell.x
		and cell.y >= upper_left_cell.y 
		and cell.y <= bottom_right_cell.y
	)

func _initialize_lights():
	for tile in wall_deco_map.get_used_cells_by_id(Globals.DECORATION_TILES.LIGHT):
		if(_is_in_room(tile)):
			var light_instance =  light.instance()
			light_instance.global_position = wall_deco_map.map_to_world(tile)
			$LightBulbs.add_child(light_instance)

func _on_RoomArea_area_entered(area):
	if (area.is_in_group('room')):
		emit_signal("declare_neighbour", area.get_parent())
	else:
		contained_characters.append(area.get_parent())

func _on_RoomArea_area_exited(area):
	if (area.is_in_group('room')):
		# TODO manage
		emit_signal("remove_neighbour", area.get_parent())
	else:
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

func _stop_alert():
	$SoundFx/Alarm.stop()
	emit_signal("alert_stopped")

func _alert_update():
	if $AlertTimer.time_left > 0:
		if not is_in_alert():
			_stop_alert()

func is_in_alert():
	for light in lights.get_children():
		if light.state == Globals.LightingState.ALERT:
			return true
	return false

func trigger_alert():
	for l in lights.get_children():
		l.change_state(Globals.LightingState.ALERT)
	$SoundFx/Alarm.play_sound()
	$AlertTimer.start()

func blackout_room():
	for light in lights.get_children():
		light.change_state(Globals.LightingState.OFF)

func get_patrol_points(world_coordinated=false):
	if world_coordinated:
		var wced = []
		for p in _patrol_points:
			wced.append(gb(p))
		return wced
	else:
		return _patrol_cells

func get_next_patrol_index(i):
	return (i + 1) % len(_patrol_points)

func _on_AlertTimer_timeout():
	if is_in_alert():
		for light in lights.get_children():
			light.change_state(Globals.LightingState.ON)
			_stop_alert()


func _on_Alarm_finished():
	if is_in_alert():
		$AlertTimer.start()

