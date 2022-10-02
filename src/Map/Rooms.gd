extends Node

onready var tilemap = $"../TileMap"

var _room_graph = {}

func _ready():
	for room in get_children():
		room.connect("declare_neighbour", self, "_new_neighbour", [room])

func _new_neighbour(room2, room1):
	var neighbours = _room_graph.get(room1, []) + [room2]
	_room_graph[room1] = neighbours

func _process(_delta):
	pass

func get_neighbours(room):
	return _room_graph[room]

func locate_player():
	for room in get_children():
		if room.contains_player():
			return room
	return null
