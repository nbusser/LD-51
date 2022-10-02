extends Character

enum Strategy {
	PATROL
	CHASE
	ALERT
}

export var strategy = Strategy.PATROL
var patrol_room setget set_patrol_room
var patrol_index = 0

onready var rooms_manager = $"../../Rooms"
onready var normal_wait_time = $MoveTick.wait_time
const SPEED_MALUS_BLIND = 2
const SPEED_BONUS_ALERT = 0.1

var is_blind = false

func _init().("../../../"):
	pass

func _ready():
	$MoveTick.wait_time = get_speed()

func get_current_patrol_point(world_coordinates=false):
	if len(patrol_room.get_patrol_points()) == 0:
		return null
	return patrol_room.get_patrol_points(world_coordinates)[patrol_index]

func _process(_delta):
	if $StartMoving.time_left == 0 and can_move():
		var origin_tile = get_map_position()
		var origin = global_position
		
		var target
		if strategy == Strategy.CHASE:
			target = self.manager.get_player_position(true)
		else:
			if get_current_patrol_point(false) == null:
				# TODO: wandering AI
				return
			
			if get_map_position() == get_current_patrol_point(false):
				patrol_index = patrol_room.get_next_patrol_index(patrol_index)
			target = get_current_patrol_point(true)

		var path = map.get_path_to_target(origin, target)
		
		if path != null:
			var destination
			if len(path) == 0:
				destination = map.tilemap.world_to_map(target)
			else:
				destination = map.tilemap.world_to_map(path[0])
			move_to(destination)

func change_speed(new_speed):
	$Tween.interpolate_property(
		$MoveTick, "wait_time",
		$MoveTick.wait_time, new_speed,
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	$Tween.start()

func get_speed():
	var speed = normal_wait_time
	if strategy == Strategy.ALERT:
		speed *= SPEED_BONUS_ALERT
	if is_blind:
		speed *= SPEED_MALUS_BLIND
	return speed

func switch_strategy(_strategy):
	strategy = _strategy

	if _strategy == Strategy.PATROL:
		start_patroling()
	else:
		$PatrolMode.stop()
	
	if _strategy == Strategy.ALERT:
		change_speed(get_speed())

func _update_blind(blind):
	is_blind = blind
	change_speed(get_speed())

func _on_EnemyBlindZone_area_entered(_area):
	_update_blind(true)

func _on_EnemyBlindZone_area_exited(_area):
	_update_blind(false)

func start_patroling():
	set_patrol_room(rooms_manager.locate_character(self))
	if patrol_room == null:
		set_patrol_room(rooms_manager.get_random_room())
	$PatrolMode.start()

func _on_StartMoving_timeout():
	if strategy == Strategy.PATROL:
		start_patroling()

func set_patrol_room(_patrol_room):
	patrol_room = _patrol_room
	patrol_index = 0
	

func _on_PatrolMode_timeout():
	if randf() < 0.7:
		var neighbours = rooms_manager.get_neighbours(rooms_manager.locate_player())
		set_patrol_room(neighbours[randi()%len(neighbours)])

func receive_alert(alert_room):
	if strategy == Strategy.PATROL:
		switch_strategy(Strategy.ALERT)
		set_patrol_room(alert_room)
	# If already on an alert, can stay in the first alert room or move
	elif strategy == Strategy.ALERT:
		if randf() < 0.5:
			set_patrol_room(alert_room)

func stop_alert(alert_room):
	if strategy == Strategy.ALERT and patrol_room == alert_room:
		switch_strategy(Strategy.PATROL)
