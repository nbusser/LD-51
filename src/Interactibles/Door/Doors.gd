extends Node

@onready var door = preload("res://src/Interactibles/Door/Door.tscn")
@onready var map = $"../../../.."
@onready var tallmap = $"../TallMap"
@onready var walkable_map = $"../WalkableMap"

var door_cells = {}

func _ready():
	var open_doors = tallmap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN_H) + tallmap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN_V)
	var closed_doors = tallmap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED_H) + tallmap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED_V)
	_instantiate_doors(open_doors, true)
	_instantiate_doors(closed_doors, false)

func _instantiate_doors(cells, opened):
	for door_pos in cells:
		var new_door = door.instantiate()
		new_door.init(self, opened, door_pos)
		new_door.position = walkable_map.map_to_local(door_pos)
		new_door.connect("open_door", Callable(self, "open_door"))
		new_door.connect("close_door", Callable(self, "close_door"))
		add_child(new_door)
		door_cells[door_pos] = new_door

func _random_door_pos():
	return door_cells.keys()[randi()%door_cells.keys().size()]

func _change_door_state(pos, opened):
	var door_t = tallmap.get_cellv(pos)
	var cellv
	if (door_t == Globals.TILE_TYPES.DOOR_CLOSED_H):
		cellv = Globals.TILE_TYPES.DOOR_OPEN_H
		walkable_map.set_cellv(pos, Globals.WALKABLE.YES)
	elif (door_t == Globals.TILE_TYPES.DOOR_CLOSED_V):
		cellv = Globals.TILE_TYPES.DOOR_OPEN_V
		walkable_map.set_cellv(pos, Globals.WALKABLE.YES)
	elif (door_t == Globals.TILE_TYPES.DOOR_OPEN_H):
		cellv = Globals.TILE_TYPES.DOOR_CLOSED_H
		walkable_map.set_cellv(pos, Globals.WALKABLE.NO)
	elif (door_t == Globals.TILE_TYPES.DOOR_OPEN_V):
		cellv = Globals.TILE_TYPES.DOOR_CLOSED_V
		walkable_map.set_cellv(pos, Globals.WALKABLE.NO)
	door_cells[pos].change_state(opened)
	tallmap.set_cellv(pos, cellv)

func open_door(region, pos):
	if region == self:
		_change_door_state(pos, true)

func close_door(region, pos):
	if region == self:
		_change_door_state(pos, false)

func switch_random_door():
	if door_cells.size() == 0:
		return
	var door_cell = _random_door_pos()
	if tallmap.get_cellv(door_cell) == Globals.TILE_TYPES.DOOR_OPEN_H || tallmap.get_cellv(door_cell) == Globals.TILE_TYPES.DOOR_OPEN_V:
		close_door(self, door_cell)
	else:
		open_door(self, door_cell)
