extends Character

func _init().("../../../"):
	pass
	
func _process(delta):
	# TODO: IA that calls move
	if can_move():
		var origin = global_position
		var target = self.manager.get_player_position(true)
		var path = map.get_path_to_target(origin, target)

		if len(path) != 0:
			var destination = map.tilemap.world_to_map(path[0])
			move_to(destination)

func accelerate():
	$MoveTick.wait_time /= 2
