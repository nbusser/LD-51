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
onready var walkable_map = $WalkableMap

func _init().():
	pass

func _ready():
	assert(path.get_point_count() != 0)
	path.visible = false
	docks = walkable_map.get_used_cells_by_id(Globals.WALKABLE.DOCK)

func _process(_delta):
	if (!is_moving):
		start_moving()

func stop_moving():
	backwards = !backwards
	is_moving = false

func reach_segment_end():
	anchor_point = next_anchor_point
	if (reached_end()):
		stop_moving()
		identify_docked_regions()
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
	next_anchor_point = get_next_anchor_point()
	prepare_next_segment()

func _on_MobileTween_tween_completed(_object, _key):
	reach_segment_end()

func identify_docked_regions():
	for d in docks:
		var world_loc = walkable_map.map_to_world(d)
		for s in static_regions.get_children():
			if (s.walkable_map.get_cellv(s.walkable_map.world_to_map(world_loc)) == Globals.WALKABLE.DOCK):
				print ("yes")
