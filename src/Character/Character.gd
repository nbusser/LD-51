extends Node2D

class_name Character

onready var move_tick_timer = $MoveTick

onready var map = get_parent().get_parent();

var _map_path = null

func _init(map_path):
	print('caca', map_path)
	_map_path = map_path

func _ready():
	# Waits for Game.gd to run randomize()
	yield(get_tree(), "idle_frame")
	$SoundFx/SpawnSound.play_sound()

	map = get_node(_map_path)
	self.position = map.tilemap.map_to_world(map.tilemap.world_to_map(global_position))

func can_move():
	return move_tick_timer.is_stopped()

func get_character_speed():
	return move_tick_timer.wait_time

func move(direction):
	var destinationTile = map.tilemap.world_to_map(global_position) + direction
	
	if direction != Vector2.ZERO and can_move() and map.isNavigable(destinationTile):
		move_tick_timer.start()
		
		var destination = map.tilemap.map_to_world(
			destinationTile
		)
		
		$Tween.interpolate_property(
			self, "position", self.position, destination, get_character_speed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
