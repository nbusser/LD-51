extends Node2D
class_name Region

onready var tilemap = $WalkableMap
onready var wall_map = $TallMap
onready var floor_map = $FloorMap
onready var wall_deco_map = $WallDecorationMap
onready var ceiling_map = $CeilingMap
onready var rooms = $Rooms
onready var astar = Astar.new([tilemap])
onready var spawners = $Spawners
onready var characters = $"../../Characters"
onready var hud = $"../../../UI/HUD"

onready var spawner = preload("res://src/Spawner/Spawner.tscn")

func _ready():
	_create_ceiling()
	initialize_walkable()
	_initialize_spawners()

func _initialize_spawners():
	for tile in wall_deco_map.get_used_cells_by_id(Globals.DECORATION_TILES.VENT):
		var spawner_instance = spawner.instance()
		spawner_instance.global_position = wall_deco_map.map_to_world(tile)
		spawners.add_child(spawner_instance)

func _create_ceiling():
	for c in floor_map.get_used_cells():
		var cell_value = floor_map.get_cellv(c)
		if cell_value == 0:
			ceiling_map.set_cell(c.x, c.y - 1, cell_value, false, false, false, floor_map.get_cell_autotile_coord(c.x, c.y))
		else:
			ceiling_map.set_cell(c.x, c.y - 1, 0, false, false, false, Vector2(2, 1))

func initialize_walkable():
	for tile in floor_map.get_used_cells():
		var tall_cell = wall_map.get_cellv(tile)
		var wall_dec_tile = wall_deco_map.get_cellv(tile)
		if ((tall_cell == -1 || tall_cell == Globals.ITEMS.CAT) && (wall_dec_tile != Globals.TILE_TYPES.DOOR_CLOSED_H) && (wall_dec_tile != Globals.TILE_TYPES.DOOR_CLOSED_V) && (tilemap.get_cellv(tile) == -1)):
			tilemap.set_cellv(tile, Globals.WALKABLE.YES)

func rebake(changed_tile):
	# Re-bake autotiling
	tilemap.update_bitmask_region(
		Vector2(changed_tile.x-1, changed_tile.y-1),
		Vector2(changed_tile.x+1, changed_tile.y+1)
	)

func isNavigable(gcoord):
	return astar.is_navigable_simple(gcoord) and not characters.is_position_occupied(gcoord)

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
