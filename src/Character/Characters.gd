extends Node

onready var tilemap = get_parent().get_node('TileMap')

var player_position = Vector2.ZERO
var enemy_positions = {}

func is_cell_occupied(cell):
	if player_position == cell:
		return true
	return enemy_positions.values().has(cell)

func update_position(character, position):
	if character == $Player:
		player_position = position
	else:
		enemy_positions[character] = position

func remove_enemy(enemy):
	enemy_positions.erase(enemy)

func init_positions():
	player_position = update_position($Player, tilemap.world_to_map($Player.position))
	for enemy in $Enemies.get_children():
		update_position(enemy, tilemap.world_to_map(enemy.position))

func _ready():
	player_position = update_position($Player, tilemap.world_to_map($Player.position))
	for enemy in $Enemies.get_children():
		update_position(enemy, tilemap.world_to_map(enemy.position))
