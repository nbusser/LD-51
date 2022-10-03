extends Node

onready var map = $"../"

var characters = []

#func reparent_all():
#	for c in characters:
#		if (!c.region.isNavigable(c.tilemap.map_to_world(character_positions[c]))):
#			var world_coords = c.to_global(c.tilemap.map_to_world(character_positions[c]))
#			var done = false
#			for r in $"../StaticAreas".get_children():
#				var local_coords = r.to_local(world_coords)
#				if (r.isNavigable(r.tilemap.map_to_world(local_coords))):
#					character_areas[c] = r
#					get_parent().remove_child(c)
#					r.characters.call_deferred("add_child", c)
#					break
#			for r in $"../MobileAreas".get_children():
#				var local_coords = r.to_local(world_coords)
#				if (r.isNavigable(r.tilemap.map_to_world(local_coords))):
#					character_areas[c] = r
#					get_parent().remove_child(c)
#					r.characters.call_deferred("add_child", c)
#					break

func get_enemies():
	var enemies = []
	for character in get_children():
		if not character.is_in_group('player'):
			enemies.append(character)
	return enemies

func is_position_occupied(gcoord):
	for c in character_positions.values():
		if (c - gcoord).size() < 0.3:
			return true
	return false

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
	for r in $"../StaticAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			characters.append(c)
			character_areas[c] = r
			character_positions[c] = r.tilemap.world_to_map(c.position)
	for r in $"../MobileAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			characters.append(c)
			character_areas[c] = r
			character_positions[c] = r.tilemap.world_to_map(c.position)
