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

func add_character(character, region_type, region_number, _region, world_pos, _cell):
	add_child(character)
	character.update_map(region_type, region_number)
	character.global_position = world_pos
	print("connection")
	character.connect("lose_hp", level, "lose_hp_player")

func _ready():
	for enemy in get_enemies():
		print("connection2")
		enemy.connect("lose_hp", level, "lose_hp_player")
	for r in $"../StaticAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			if c.is_in_group("player"):
				player = c
			characters.append(c)
	for r in $"../MobileAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			if c.is_in_group("player"):
				player = c
			characters.append(c)
