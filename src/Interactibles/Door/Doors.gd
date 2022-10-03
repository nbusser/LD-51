extends Node

onready var door = preload("res://src/Interactibles/Door/Door.tscn")
onready var map = $"../"

var door_cells = {}

func _ready():
	for s_area in map.get_node("StaticAreas").get_children():
		var tilemap = s_area.get_node("WallDecorationMap")
		var open_doors = tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN_H) + tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN_V)
		var closed_doors = tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED_H) + tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED_V)
		_instantiate_doors(s_area, open_doors, true)
		_instantiate_doors(s_area, closed_doors, false)
	for m_area in map.get_node("MobileAreas").get_children():
		var tilemap = m_area.get_node("WallDecorationMap")
		var open_doors = tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN_H) + tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN_V)
		var closed_doors = tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED_H) + tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED_V)
		_instantiate_doors(m_area, open_doors, true)
		_instantiate_doors(m_area, closed_doors, false)
	

func _instantiate_doors(area, cells, opened):
	for door_pos in cells:
		var new_door = door.instance()
		new_door.init(area, opened, door_pos)
		new_door.position = area.get_node("WalkableMap").map_to_world(door_pos)
		new_door.connect("open_door", self, "open_door")
		new_door.connect("close_door", self, "close_door")

		add_child(new_door)
		door_cells[door_pos] = new_door
		
func _random_door_pos():
	return door_cells.keys()[randi()%door_cells.keys().size()]

func _change_door_state(area, pos, opened):
	var tilemap = area.get_node("WallDecorationMap")
	var walkable_map = area.get_node("WalkableMap")
	var door = tilemap.get_cellv(pos)
	var cellv
	if (door == Globals.TILE_TYPES.DOOR_CLOSED_H):
		cellv = Globals.TILE_TYPES.DOOR_OPEN_H
		walkable_map.set_cellv(pos, Globals.WALKABLE.YES)
	elif (door == Globals.TILE_TYPES.DOOR_CLOSED_V):
		cellv = Globals.TILE_TYPES.DOOR_OPEN_V
		walkable_map.set_cellv(pos, Globals.WALKABLE.YES)
	elif (door == Globals.TILE_TYPES.DOOR_OPEN_H):
		cellv = Globals.TILE_TYPES.DOOR_CLOSED_H
		walkable_map.set_cellv(pos, Globals.WALKABLE.NO)
	elif (door == Globals.TILE_TYPES.DOOR_OPEN_V):
		cellv = Globals.TILE_TYPES.DOOR_CLOSED_V
		walkable_map.set_cellv(pos, Globals.WALKABLE.NO)
	door_cells[pos].change_state(opened)
	tilemap.set_cellv(pos, cellv)

func open_door(area, pos):
	_change_door_state(area, pos, true)

func close_door(area, pos):
	_change_door_state(area, pos, false)

func switch_random_door(area):
	var tilemap = area.get_node("WallDecorationMap")
	if door_cells.size() == 0:
		return
	var door_cell = _random_door_pos()
	if tilemap.get_cellv(door_cell) == Globals.TILE_TYPES.DOOR_OPEN:
		close_door(area, door_cell)
	else:
		open_door(area, door_cell)
