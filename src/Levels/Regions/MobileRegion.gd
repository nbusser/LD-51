extends Region

var anchor_point = 0
onready var path = $Line2D
onready var tween = $MobileTween
var backwards = false
var is_moving = false
var next_anchor_point = 1
var segment
var speed = 50

func _init().():
	pass

func _ready():
	assert(path.get_point_count() != 0)
	path.visible = false

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
