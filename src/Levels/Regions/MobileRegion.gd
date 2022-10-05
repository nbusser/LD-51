extends Region

var anchor_point = 0
onready var path = $Line2D
onready var tween = $MobileTween
var backwards = false
var is_moving = false
var next_anchor_point = 1
var segment
var speed = 200
onready var docks = []
onready var static_regions = $"../../StaticAreas"
onready var mobile_regions = $"../../MobileAreas"
onready var g_characters = $"../../Characters"
onready var walkable_map = $WalkableMap

var docked_regions = []

func _init().():
	pass

func _ready():
	assert(path.get_point_count() != 0)
	path.visible = false
	docks = walkable_map.get_used_cells_by_id(Globals.WALKABLE.DOCK)
	update_docked_regions()
	refresh_dock()

func _process(_delta):
	if (!is_moving && randi()%600 == 300):
		start_moving()

func stop_moving():
	backwards = !backwards
	is_moving = false
	update_docked_regions()
	refresh_dock()

func reach_segment_end():
	anchor_point = next_anchor_point
	if (reached_end()):
		stop_moving()
		return
	get_next_anchor_point()
	prepare_next_segment()

func reached_end():
	return ((!backwards && (anchor_point == path.get_point_count() - 1)) || (backwards && (anchor_point == 0)))

func get_next_anchor_point():
	if (!backwards):
		return (anchor_point + 1)%path.get_point_count()
	else:
		return (anchor_point - 1)%path.get_point_count()

func prepare_next_segment():
	var diff = path.get_point_position(anchor_point) - path.get_point_position(next_anchor_point)
	var duration = diff.length()/speed
	tween.interpolate_property(
		self, "position", self.position, self.position - diff, duration, Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()

func start_moving():
	is_moving = true
	for r in docked_regions:
		r.undock(self)
	docked_regions = []
	next_anchor_point = get_next_anchor_point()
	prepare_next_segment()
	refresh_undock()

func _on_MobileTween_tween_completed(_object, _key):
	reach_segment_end()

func get_reachable(array):
	for m in docked_regions:
		if (!array.has(m)):
			array.append(m)
			get_reachable(array)
	return array

func update_astar():
	var reachable = get_reachable([self])
	var tilemaps = []
	for r in reachable:
		tilemaps.append(r.walkable_map)
	astar = Astar.new(tilemaps)

func refresh_dock():
	for s in static_regions.get_children():
		s.update_astar()
	for m in mobile_regions.get_children():
		m.update_astar()

func refresh_undock():
	refresh_dock()

func update_docked_regions():
	for d in docks:
		var world_loc = walkable_map.to_global(walkable_map.map_to_world(d))
		for s in static_regions.get_children():
			var local = s.to_local(world_loc)
			if (s.walkable_map.get_cellv(s.walkable_map.world_to_map(local)) == Globals.WALKABLE.DOCK):
				docked_regions.append(s)
				s.dock(self)
				continue
