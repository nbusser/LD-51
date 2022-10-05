extends Node

onready var map = $"../"
onready var level = $"../../"

var characters = []
var player = null

func get_enemies():
	var enemies = []
	for character in get_children():
		if not character.is_in_group('player'):
			enemies.append(character)
	return enemies

func is_position_occupied(gcoord):
	for c in characters:
		if (c.global_position - gcoord).length() < 16:
			return true
	return false

func add_character(character, region_type, region_number, region, world_pos, cell):
	add_child(character)
	character.update_map(region_type, region_number)
	character.global_position = world_pos
	character.connect("kill", level, "kill_player")
	character.connect("lose_hp", level, "lose_hp_player")

func init_positions(area):
	for character in get_children():
		var tilemap = area.get_node("WalkableMap")

func _ready():
	init_positions(get_node("../StaticAreas").get_children()[0])
	for enemy in get_enemies():
		enemy.connect("kill", map, "kill_player")
		enemy.connect("lose_hp", level, "lose_hp_player")
	for r in $"../StaticAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			if c.is_in_group("player"):
				player = r
			characters.append(c)
	for r in $"../MobileAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			if c.is_in_group("player"):
				player = r
			characters.append(c)
