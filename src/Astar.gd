extends Reference
class_name Astar

var tilemaps

func _init(new_tilemaps):
	self.tilemaps = new_tilemaps

func is_navigable_type(tile_type):
	return tile_type != -1

func is_navigable_simple(pos):
	for t in tilemaps:
		var local_pos = t.to_global(pos)
		if is_navigable_type(t.get_cellv(t.world_to_map(local_pos))):
			return true
	return false

func get_navigable_neighbors(x, y):
	var res = []
	if is_navigable_simple(Vector2(x, y + 32)):
		res.append(Vector2(x, y + 32))
	if is_navigable_simple(Vector2(x, y - 32)):
		res.append(Vector2(x, y - 32))
	if is_navigable_simple(Vector2(x - 32, y)):
		res.append(Vector2(x - 32, y))
	if is_navigable_simple(Vector2(x + 32, y)):
		res.append(Vector2(x + 32, y))
	return res

func heuristic(current, goal):
	return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y, 2))

func path_from_backtrack_map(bm, current):
	var path = []
	while bm.has(current):
		path.append(current + Vector2(16, 16))
		current = bm[current]
	path.invert()
	return path

func get_path_to_target(origin, destination):
	print(origin, " *-* ", destination)
	var frontier = PriorityQueue.new()
	var backtrack_map = {}
	var computed_costs = {}
	computed_costs[origin] = 0
	frontier.push(origin, heuristic(origin, destination))
	
	var i = 0
	
	while not frontier.is_empty():
		var current = frontier.pop()
		if (current - destination).length() < 40:
			return path_from_backtrack_map(backtrack_map, current)
		for candidate in get_navigable_neighbors(current.x, current.y):
			var cost = computed_costs[current] + 1
			if !computed_costs.has(candidate) || cost < computed_costs[candidate]:
				computed_costs[candidate] = cost
				backtrack_map[candidate] = current
				frontier.push(candidate, cost + heuristic(current, destination))
	return null
