extends Node2D

onready var tilemap = $Navigation2D/TileMap
onready var astar = Astar.new(tilemap)
onready var characters = $Navigation2D/Characters
onready var items = $Navigation2D/Items
onready var hud = get_node("../UI/HUD")

var door_cells = null

func _ready():
	door_cells = tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_OPEN) + tilemap.get_used_cells_by_id(Globals.TILE_TYPES.DOOR_CLOSED)
	hud.set_coins(items.get_used_cells_by_id(Globals.CATS.CAT).size())

func add_door():
	var door = door_cells[randi()%door_cells.size()]
	if (tilemap.get_cellv(door) == Globals.TILE_TYPES.DOOR_CLOSED):
		tilemap.set_cellv(door, Globals.TILE_TYPES.DOOR_OPEN)
	else:
		tilemap.set_cellv(door, Globals.TILE_TYPES.DOOR_CLOSED)

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
	$Navigation2D/Items.set_cellv(pos, -1)
	hud.increment_coins()
