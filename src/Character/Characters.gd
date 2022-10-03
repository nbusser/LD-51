extends Node

var character_areas = {}
var character_positions = {}

func is_cell_occupied(cell):
	return character_positions.values().has(cell)

func change_area(character, area, position):
	character_areas[character] = area
	character_positions[character] = position

func update_position(character, position):
	character_positions[character] = position

func remove_character(character):
	character_areas.erase(character)
	character_positions.erase(character)

func init_positions(area):
	for character in get_children():
		var tilemap = area.get_node("WalkableMap")
		change_area(character, area, tilemap.world_to_map(character.position))

# TODO local coordinates used when?
func get_player_position(world_coordinates=false):
	var pos = character_positions.get($Player)
	if world_coordinates:
		var tilemap = character_areas.get($Player).get_node("WalkableMap")
		pos = tilemap.map_to_world(pos)
	return pos

func _ready():
	init_positions(get_node("../StaticAreas").get_children()[0])
