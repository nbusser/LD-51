signal position_changed(character, new_position)

extends Node2D

class_name Character

onready var move_tick_timer = $MoveTick

var tilemap
onready var manager = get_parent()

var _region_type
var _region_number
var region = null

func _init(region_type, region_number):
	_region_type = region_type
	_region_number = region_number

func handle_region_switch(old_region):
	pass

func update_map(region_type, region_number):
	var old_region = region
	_region_type = region_type
	_region_number = region_number
	if (_region_type == Globals.REGION_TYPE.STATIC):
		region = self.get_node("../../StaticAreas").get_children()[region_number]
	else:
		region = self.get_node("../../MobileAreas").get_children()[region_number]
	tilemap = region.get_node("WalkableMap")
	handle_region_switch(old_region)

func _ready():
	# Waits for Game.gd to run randomize()
	yield(get_tree(), "idle_frame")
	$SoundFx/SpawnSound.play_sound()

	update_map(_region_type, _region_number)
	self.position = tilemap.map_to_world(get_map_position())
	
	self.connect("position_changed", manager, "update_position")

func get_map_position():
	return tilemap.world_to_map(position)

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
	if get_map_position() != destination_tile and can_move() and region.isNavigable(destination_tile):
		move_tick_timer.start()
		
		var destination = tilemap.map_to_world(destination_tile)
		
		emit_signal("position_changed", self, destination_tile)
		
		$Tween.interpolate_property(
			self, "position", self.position, destination, get_character_speed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
