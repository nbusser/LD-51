extends Character

signal lose_hp

enum Strategy {
	PATROL,
	CHASE,
	ALERT
}

@export var strategy = Strategy.PATROL
var patrol_room : set = set_patrol_room
var patrol_index = 0

var rooms_manager = null

@onready var patrol_speed = $MoveTick.wait_time
@onready var chase_speed = patrol_speed * 0.3

const SPEED_MALUS_BLIND = 1.5
const SPEED_BONUS_ALERT = 0.5

@onready var characters_manager = $"../"

var blind_sources = []

var cannot_reach_dest_counter = 0

func handle_region_switch(_old_region):
	rooms_manager = region.get_node("Rooms")

func _ready():
	update_speed()

func get_current_patrol_point(world_coordinates=false):
	if len(patrol_room.get_patrol_points()) == 0:
		return null
	return patrol_room.get_patrol_points(world_coordinates)[patrol_index]
	
func _get_animation_ref():
	var animation = super._get_animation_ref()
	if is_blind():
		animation = "dazzle_" + animation
	return animation

var first = true

func _process(_delta):
	var detection_cone_rotation
	if direction == UP:
		detection_cone_rotation = 180
	elif direction == RIGHT:
		detection_cone_rotation = -90
	elif direction == DOWN:
		detection_cone_rotation = 0
	else:
		detection_cone_rotation = 90
	$DetectionArea.rotation_degrees = detection_cone_rotation
	
	if $StartMoving.time_left == 0 and can_move():
		var origin_tile = get_tile(global_position)
		var origin = region.to_global(region.tilemap.map_to_local(origin_tile))
		var target
		
		if strategy == Strategy.CHASE:
			target = characters.player.global_position
		else:
			if get_current_patrol_point(true) == null:
				# TODO: wandering AI
				return
			if get_tile(global_position) == get_current_patrol_point(false):
				patrol_index = patrol_room.get_next_patrol_index(patrol_index)
			target = region.to_global(region.tilemap.map_to_local(get_current_patrol_point(false)))
			if first:
				first = false
		var path = region.get_path_to_target(origin, target)
		if path != null:
			var destination
			if len(path) == 0:
				destination = target
				if strategy == Strategy.CHASE && (self.global_position - characters.player.global_position).length() <= 32:
					emit_signal("lose_hp")
			else:
				destination = path[0]
			move_to(destination)
		else:
			if strategy == Strategy.CHASE:
				target = characters.player.global_position + Vector2(0, -32)
				path = region.get_path_to_target(origin, target)
				if path != null:
					var destination
					if len(path) == 0:
						destination = target
						if strategy == Strategy.CHASE && (self.global_position - characters.player.global_position).length() <= 32:
							emit_signal("lose_hp")
					else:
						destination = path[0]
					move_to(destination)
					return
			cannot_reach_dest_counter += 1
			if cannot_reach_dest_counter == 60:
				cannot_reach_dest_counter = 0
				switch_strategy(Strategy.PATROL)

func _change_speed(new_speed):
	$Tween.interpolate_property(
		$MoveTick, "wait_time", $MoveTick.wait_time, new_speed, 0.1, Tween.TRANS_CUBIC,
		Tween.EASE_IN
	)
	$Tween.start()

func _get_speed():
	var speed = chase_speed if strategy == Strategy.CHASE else patrol_speed
	if not $AlertSpeedBoost.is_stopped():
		speed *= SPEED_BONUS_ALERT
	if is_blind():
		speed *= SPEED_MALUS_BLIND
	return speed

func update_speed():
	var new_speed = _get_speed()
	if new_speed != $MoveTick.wait_time:
		_change_speed(new_speed)

func switch_strategy(_strategy):
	var old_strategy = strategy
	strategy = _strategy
	if _strategy == Strategy.CHASE and old_strategy != strategy:
		$SoundFx/ChaseSound.play_sound()
	if _strategy == Strategy.PATROL:
		start_patroling()
	else:
		$PatrolMode.stop()
	if _strategy == Strategy.ALERT:
		$AlertSpeedBoost.start()

	update_speed()

func is_blind():
	return len(blind_sources) > 0

func _on_EnemyBlindZone_area_entered(_area):
#	if _area.is_in_group("flashlight"):
#		switch_strategy(Strategy.CHASE)
	$SoundFx/GrowlSound.play_sound()
	blind_sources.append(_area)
	update_speed()

func _on_EnemyBlindZone_area_exited(_area):
	blind_sources.erase(_area)
	update_speed()

func start_patroling():
	set_patrol_room(rooms_manager.locate_character(self))
	if patrol_room == null:
		set_patrol_room(rooms_manager.get_random_room())
	$PatrolMode.start()

func _on_StartMoving_timeout():
	switch_strategy(strategy)

func set_patrol_room(_patrol_room):
	patrol_room = _patrol_room
	patrol_index = 0

func _on_PatrolMode_timeout():
	if randf() < 0.7:
		var room = rooms_manager.locate_character(self)
		if (room == null):
			print("WARNING: enemy should never be out a room")
			return
		var neighbours = rooms_manager.get_neighbours(room)
		if len(neighbours) > 0:
			set_patrol_room(neighbours[randi()%len(neighbours)])

func receive_alert(alert_room):
	if strategy == Strategy.PATROL:
		switch_strategy(Strategy.ALERT)
		set_patrol_room(alert_room)
	# If already on an alert, can stay in the first alert room or move
	elif strategy == Strategy.ALERT:
		switch_strategy(Strategy.ALERT)
		if randf() < 0.5:
			set_patrol_room(alert_room)

func stop_alert(alert_room):
	if strategy == Strategy.ALERT and patrol_room == alert_room:
		switch_strategy(Strategy.PATROL)

func _on_DetectionArea_area_entered(_area):
	# TODO: raycast for walls ?
	switch_strategy(Strategy.CHASE)


func _on_LostPlayerArea_area_exited(_area):
	if strategy == Strategy.CHASE:
		switch_strategy(Strategy.PATROL)

func _on_AlertSpeedBoost_timeout():
	update_speed()
