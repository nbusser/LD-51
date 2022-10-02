extends Reference
class_name Astar

var tilemap: TileMap

func _init(new_tilemap: TileMap):
	self.tilemap = new_tilemap

func is_navigable_type(tile_type):
	return tile_type != -1

func is_navigable_simple(tile):
	return is_navigable_type(tilemap.get_cell(tile.x, tile.y))

func get_navigable_neighbors(x, y):
	var res = []
	if is_navigable_simple(Vector2(x, y + 1)):
		res.append(Vector2(x, y + 1))
	if is_navigable_simple(Vector2(x, y - 1)):
		res.append(Vector2(x, y - 1))
	if is_navigable_simple(Vector2(x - 1, y)):
		res.append(Vector2(x - 1, y))
	if is_navigable_simple(Vector2(x + 1, y)):
		res.append(Vector2(x + 1, y))
	return res


func heuristic(current, goal):
	return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y, 2))

func path_from_backtrack_map(bm, current):
	var path = []
	while bm.has(current):
		path.append(tilemap.map_to_world(current) + Vector2(16, 16))
		current = bm[current]
	path.invert()
	return path

func get_path_to_target(origin, destination):
	var origin_tile = tilemap.world_to_map(origin)
	var destination_tile = tilemap.world_to_map(destination)
	
	var frontier = PriorityQueue.new()
	var backtrack_map = {}
	var computed_costs = {}
	computed_costs[origin_tile] = 0
	frontier.push(origin_tile, heuristic(origin_tile, destination))
	
	while not frontier.is_empty():
		var current = frontier.pop()
		if (current - destination_tile).length() < 1.2:
			return path_from_backtrack_map(backtrack_map, current)
		for candidate in get_navigable_neighbors(current.x, current.y):
			var cost = computed_costs[current] + 1
			if !computed_costs.has(candidate) || cost < computed_costs[candidate]:
				computed_costs[candidate] = cost
				backtrack_map[candidate] = current
				frontier.push(candidate, cost + heuristic(current, destination_tile))
	return null
