signal position_changed(character, new_position)

extends Node2D

class_name Character

onready var move_tick_timer = $MoveTick

var map
onready var manager = get_parent()

var _map_path = null

func _init(map_path):
	_map_path = map_path

func _ready():
	# Waits for Game.gd to run randomize()
	yield(get_tree(), "idle_frame")
	$SoundFx/SpawnSound.play_sound()

	map = get_node(_map_path)
	self.position = map.tilemap.map_to_world(get_map_position())
	
	self.connect("position_changed", manager, "update_position")

func get_map_position():
	return map.tilemap.world_to_map(position)

func can_move():
	return move_tick_timer.is_stopped()

func get_character_speed():
	return move_tick_timer.wait_time

func move(direction):
	var destination_tile = get_map_position() + direction
	move_to(destination_tile)

func move_to(destination_tile):
	if not Globals.can_interact:
		return

	if get_map_position() != destination_tile and can_move() and map.isNavigable(destination_tile):
		move_tick_timer.start()
		
		var destination = map.tilemap.map_to_world(
			destination_tile
		)
		
		emit_signal("position_changed", self, destination_tile)
		
		$Tween.interpolate_property(
			self, "position", self.position, destination, get_character_speed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
