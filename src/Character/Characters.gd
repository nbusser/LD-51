extends Node

onready var map = $"../"

var character_areas = {}
var character_positions = {}

func get_enemies():
	var enemies = []
	for character in get_children():
		if not character.is_in_group('player'):
			enemies.append(character)
	return enemies

func is_cell_occupied(cell):
	return character_positions.values().has(cell)

func change_area(character, area, position):
	character_areas[character] = area
	character_positions[character] = position

func update_position(character, position):
	character_positions[character] = position
	
func add_character(character, region_type, region_number, region, world_pos, cell):
	add_child(character)
	character.update_map(region_type, region_number)
	character_areas[character] = region
	character_positions[character] = cell
	character.global_position = world_pos
	character.connect("kill", map, "kill_player")

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
	for enemy in get_enemies():
		enemy.connect("kill", map, "kill_player")
