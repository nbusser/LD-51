extends Node2D

onready var region_node = $"../../"
onready var region_type_node = $"../../../"
onready var enemy = preload("res://src/Character/Enemy/Enemy.tscn")

var region_number
var region_type

var pos

func init(_pos):
	pos = _pos

func _ready():
	if region_type_node.get_name() == "StaticAreas":
		region_type = Globals.REGION_TYPE.STATIC
	else:
		region_type = Globals.REGION_TYPE.MOBILE
	region_number = region_node.get_index()

func dispose(enemy):
#	enemy.init(region_type, region_number)
#	enemy.global_position = global_position
	queue_free()
