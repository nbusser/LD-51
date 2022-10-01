extends Node2D

onready var map = get_parent().get_parent()
onready var move_tick_timer = $MoveTick

func _ready():
	# Waits for Game.gd to run randomize()
	yield(get_tree(), "idle_frame")
	$SoundFx/SpawnSound.play_sound()
	
	self.position = map.tilemap.map_to_world(map.tilemap.world_to_map(global_position))

func can_move():
	return move_tick_timer.is_stopped()

func get_player_speed():
	return move_tick_timer.wait_time

func _process(delta):
	var direction := Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	# No diagonal move
	if(direction.x != 0 and direction.y != 0):
		direction.y = 0

	var destinationTile = map.tilemap.world_to_map(global_position) + direction
	
	if direction != Vector2.ZERO and can_move() and map.isNavigable(destinationTile):
		move_tick_timer.start()
		
		var destination = map.tilemap.map_to_world(
			destinationTile
		)
		
		$Tween.interpolate_property(
			self, "position", self.position, destination, get_player_speed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
