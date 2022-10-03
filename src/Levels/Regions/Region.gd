extends Node2D

onready var tilemap = $WalkableMap
onready var wall_map = $TallMap
onready var floor_map = $FloorMap
onready var wall_deco_map = $WallDecorationMap
onready var ceiling_map = $CeilingMap
onready var rooms = $Rooms
onready var astar = Astar.new(tilemap)
onready var characters = $"../../Characters"
onready var hud = $"../../../UI/HUD"

func _ready():
	_create_ceiling()
	initialize_walkable()

func _create_ceiling():
	for c in floor_map.get_used_cells():
		ceiling_map.set_cell(c.x, c.y - 1, 0, false, false, false, floor_map.get_cell_autotile_coord(c.x, c.y))

func initialize_walkable():
	for tile in floor_map.get_used_cells():
		var tall_cell = wall_map.get_cellv(tile)
		var wall_dec_tile = wall_deco_map.get_cellv(tile)
		if ((tall_cell == -1 || tall_cell == Globals.ITEMS.CAT) && (wall_dec_tile != Globals.TILE_TYPES.DOOR_CLOSED_H) && (wall_dec_tile != Globals.TILE_TYPES.DOOR_CLOSED_V)):
			tilemap.set_cellv(tile, Globals.WALKABLE.YES)

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
	wall_map.set_cellv(pos, -1)
	hud.increment_coins()

func calculate_bounds():
	var cell_bounds = floor_map.get_used_rect()
	# create transform
	var cell_to_pixel = Transform2D(Vector2(floor_map.cell_size.x * floor_map.scale.x, 0), Vector2(0, floor_map.cell_size.y * floor_map.scale.y), Vector2())
	# apply transform
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)
