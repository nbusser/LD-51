extends Node2D

var door_cells = null
onready var tilemap = $TileMap

enum TILE_TYPES {
	AISLE = 0,
	GROUND = 12,
	DOOR_OPEN = 13
	DOOR_CLOSED = 15
}

func _ready():
	door_cells = tilemap.get_used_cells_by_id(TILE_TYPES.DOOR_OPEN) + tilemap.get_used_cells_by_id(TILE_TYPES.DOOR_CLOSED)

func add_door():
	var door = door_cells[randi()%door_cells.size()]
	if (tilemap.get_cellv(door) == TILE_TYPES.DOOR_CLOSED):
		tilemap.set_cellv(door, TILE_TYPES.DOOR_OPENED)
	else:
		tilemap.set_cellv(door, TILE_TYPES.DOOR_CLOSED)

func rebake(changed_tile):
	# Re-bake autotiling
	tilemap.update_bitmask_region(
		Vector2(changed_tile.x-1, changed_tile.y-1),
		Vector2(changed_tile.x+1, changed_tile.y+1)
	)
