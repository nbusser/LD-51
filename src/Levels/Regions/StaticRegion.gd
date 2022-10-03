extends Region

onready var walkable_map = $WalkableMap
var docked = []

func _init().():
	pass

func dock(mobile):
	pass

func undock(mobile):
	docked.erase(mobile)	
