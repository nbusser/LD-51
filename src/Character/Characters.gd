extends Node

onready var tilemap = get_parent().get_node("WalkableMap")

var character_positions = {}

func is_cell_occupied(cell):
	return character_positions.values().has(cell)

func update_position(character, position):
	character_positions[character] = position

func remove_character(character):
	character_positions.erase(character)

func init_positions():
	for character in get_children():
		update_position(character, tilemap.world_to_map(character.position))

func get_player_position(world_coordinates=false):
	var pos = character_positions.get($Player)
	if world_coordinates:
		pos = tilemap.map_to_world(pos)
	return pos

func _ready():
	init_positions()
