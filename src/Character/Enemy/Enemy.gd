extends Character

onready var normal_wait_time = $MoveTick.wait_time
const SPEED_MALUS_BLIND = 2

var is_blind = false

func _init().("../../../"):
	pass
	
func _process(_delta):
	if can_move():
		var origin = global_position
		var target = self.manager.get_player_position(true)
		var path = map.get_path_to_target(origin, target)

		if path != null and len(path) != 0:
			var destination = map.tilemap.world_to_map(path[0])
			move_to(destination)

func change_speed(new_speed):
	$Tween.interpolate_property(
		$MoveTick, "wait_time",
		$MoveTick.wait_time, new_speed,
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	$Tween.start()


func _on_EnemyBlindZone_area_entered(_area):
	is_blind = true
	change_speed(normal_wait_time*SPEED_MALUS_BLIND)


func _on_EnemyBlindZone_area_exited(_area):
	is_blind = false
	change_speed(normal_wait_time)
