extends Area2D

onready var tilemap = $"../../TileMap"
onready var doors_manager = $"../../Doors"

var doors_positions

func _ready():
	if $RoomShape.shape == null:
		print('ERROR: missing room shape for', self)
