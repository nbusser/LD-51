extends Node2D

onready var tilemap = $Navigation2D/WalkableMap
onready var astar = Astar.new(tilemap)
onready var characters = $Navigation2D/Characters
onready var player = $Navigation2D/Characters/Player
onready var items = $Navigation2D/TallMap
onready var hud = get_node("../UI/HUD")
onready var doors = $Navigation2D/Doors
onready var rooms = $Navigation2D/Rooms

var door_cells = null

func _ready():
	hud.set_coins(items.get_used_cells_by_id(Globals.ITEMS.CAT).size())

func switch_random_door():
	doors.switch_random_door()

func rebake(changed_tile):
	# Re-bake autotiling
	tilemap.update_bitmask_region(
		Vector2(changed_tile.x-1, changed_tile.y-1),
		Vector2(changed_tile.x+1, changed_tile.y+1)
	)

func isNavigable(tile):
	return astar.is_navigable_simple(tile) and not characters.is_cell_occupied(tile)

func get_path_to_target(origin, target):
	return astar.get_path_to_target(origin, target)

func save_cat(pos):
	$Navigation2D/TallMap.set_cellv(pos, -1)
	hud.increment_coins()

func lights_off():
	var calamitables = player.get_node("CalamitySensor").get_overlapping_areas()
	var lights = []
	for calamitable in calamitables:
		if(calamitable.is_calamitable() and calamitable.interactible_type == Globals.Interactibles.LIGHT):
			lights.append(calamitable)
	
	if len(lights) == 0:
		return

	lights[0].change_state(Globals.LightingState.OFF)

func close_doors():
	var calamitables = player.get_node("CalamitySensor").get_overlapping_areas()
	var doors = []
	for calamitable in calamitables:
		if(calamitable.is_calamitable() and calamitable.interactible_type == Globals.Interactibles.DOOR):
			doors.append(calamitable)
	
	if len(doors) == 0:
		return

	doors[0].close()

func _trigger_alert(room):
	room.trigger_alert()
	for character in $Navigation2D/Characters.get_children():
		if not character.is_in_group("player"):
			character.receive_alert(room)

func room_alert():
	var room = rooms.locate_player()
	_trigger_alert(room)
	
func neighbour_room_alert():
	var room_list = rooms.get_neighbours(rooms.locate_player())
	if len(room_list) != 0:
		_trigger_alert(room_list[randi() % len(room_list)])

func spawn_monster():
	pass
