extends Node

onready var door = preload("res://src/Interactibles/Door/Door.tscn")
onready var map = $"../../"
onready var tilemap = $"../TileMap"

var door_cells = {}

func _ready():
	var opened_doors = tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN)
	var closed_doors = tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED)

	_instantiate_doors(opened_doors, true)
	_instantiate_doors(closed_doors, false)

func _instantiate_doors(cells, opened):
	for door_pos in cells:
		var new_door = door.instance()
		new_door.init(opened, door_pos)
		new_door.position = tilemap.map_to_world(door_pos)
		new_door.connect("open_door", self, "open_door")
		new_door.connect("close_door", self, "close_door")

		add_child(new_door)
		door_cells[door_pos] = new_door
		
func _random_door_pos():
	return door_cells.keys()[randi()%door_cells.keys().size()]

func _change_door_state(pos, opened):
	var door = door_cells[pos]
	var cellv = Globals.TILE_TYPES.DOOR_OPEN if opened else Globals.TILE_TYPES.DOOR_CLOSED
	door.change_state(opened)
	tilemap.set_cellv(pos, cellv)

func open_door(pos):
	_change_door_state(pos, true)

func close_door(pos):
	_change_door_state(pos, false)

func switch_random_door():
	if door_cells.size() == 0:
		return

	var door_cell = _random_door_pos()
	if tilemap.get_cellv(door_cell) == Globals.TILE_TYPES.DOOR_OPEN:
		close_door(door_cell)
	else:
		open_door(door_cell)
