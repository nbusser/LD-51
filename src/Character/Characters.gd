extends Node

onready var map = $"../"
onready var level = $"../../"

var characters = []
var player = null

func add_character(character, region, world_pos):
	region.get_node("Characters").add_child(character)
	character.update_map(region)
	character.global_position = world_pos
	character.connect("lose_hp", level, "lose_hp_player")

func _ready():
	for r in $"../StaticAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			if c.is_in_group("player"):
				player = c
			else:
				c.connect("lose_hp", level, "lose_hp_player")
			characters.append(c)
	for r in $"../MobileAreas".get_children():
		yield(r, "ready")
		for c in r.get_node("Characters").get_children():
			if c.is_in_group("player"):
				player = c
			characters.append(c)
