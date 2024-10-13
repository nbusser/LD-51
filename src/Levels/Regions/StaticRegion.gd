extends Region

@onready var walkable_map = $WalkableMap
var docked = []

func _init():
	# super() TODO commented out as part of the upgrade to Godot 4
	pass

func dock(mobile):
	docked.append(mobile)

func undock(mobile):
	docked.erase(mobile)

func update_astar():
	var reachable = get_reachable([self])
	var tilemaps = []
	for r in reachable:
		tilemaps.append(r.walkable_map)
	astar = Astar.new(tilemaps)

func get_reachable(array):
	for m in docked:
		if (!array.has(m)):
			array.append(m)
			get_reachable(array)
	return array
	
	
