extends Node

onready var characters = $"../../../Characters"
onready var tilemap = $"../WalkableMap"

var _room_graph = {}

func _ready():
	for room in get_children():
		room.connect("declare_neighbour", self, "_new_neighbour", [room])
		room.connect("remove_neighbour", self, "_rm_neighbour", [room])
		room.connect("alert_stopped", self, "stop_alert", [room])

func _new_neighbour(room2, room1):
	var neighbours = _room_graph.get(room1, []) + [room2]
	_room_graph[room1] = neighbours

func _rm_neighbour(room2, room1):
	var neighbours = _room_graph.get(room1, [])
	neighbours.erase(room2)
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

func locate_character(character):
	for room in get_children():
		if room.contains_character(character):
			return room
	return null

func get_random_room():
	var rooms = get_children()
	return rooms[randi()%len(rooms)]

func stop_alert(room):
	for character in characters.get_children():
		if not character.is_in_group("player"):
			character.stop_alert(room)
