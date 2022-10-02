extends Character

enum Strategy {
	PATROL
	CHASE
	ALERT
}

export var strategy = Strategy.PATROL
var patrol_room
var patrol_index = 0

onready var rooms_manager = $"../../Rooms"
onready var normal_wait_time = $MoveTick.wait_time
const SPEED_MALUS_BLIND = 2

var is_blind = false

func _init().("../../../"):
	pass

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

func switch_strategy(strategy):
	if strategy == Strategy.PATROL:
		start_patroling()
	else:
		$PatrolMode.stop()

func _on_EnemyBlindZone_area_entered(_area):
	is_blind = true
	change_speed(normal_wait_time*SPEED_MALUS_BLIND)


func _on_EnemyBlindZone_area_exited(_area):
	is_blind = false
	change_speed(normal_wait_time)

func start_patroling():
	patrol_room = rooms_manager.locate_character(self)	
	if patrol_room == null:
		patrol_room = rooms_manager.get_random_room()
	$PatrolMode.start()

func _on_StartMoving_timeout():
	if strategy == Strategy.PATROL:
		start_patroling()


func _on_PatrolMode_timeout():
	if true or randi()%2:
		var neighbours = rooms_manager.get_neighbours(rooms_manager.locate_player())
		patrol_room = neighbours[randi()%len(neighbours)]
		patrol_index = 0
		print(patrol_room)
