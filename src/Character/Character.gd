signal position_changed(character, new_position)

extends Node2D

class_name Character

onready var move_tick_timer = $MoveTick
onready var characters = $"../../../../Characters"

var tilemap
onready var manager = get_parent()

const UP = Vector2(0, -32)
const DOWN = Vector2(0, 32)
const LEFT = Vector2(-32, 0)
const RIGHT = Vector2(32, 0)

var direction = DOWN

var _region_type
var _region_number
var region = null

export var initial_region_type = Globals.REGION_TYPE.STATIC
export var initial_region_number = 0

func init(region_type, region_number):
	update_map(region_type, region_number)

func handle_region_switch(old_region):
	pass

func update_map(region_type, region_number):
	var old_region = region
	_region_type = region_type
	_region_number = region_number
	print(self, " ", region_type, " ", region_number, " ", self.get_node("../../.."))
	if (_region_type == Globals.REGION_TYPE.STATIC):
		region = self.get_node("../../../../StaticAreas").get_children()[region_number]
	else:
		region = self.get_node("../../../../MobileAreas").get_children()[region_number]
	tilemap = region.get_node("WalkableMap")
	handle_region_switch(old_region)

func _ready():
	# Waits for Game.gd to run randomize()
	yield(get_tree(), "idle_frame")
	$SoundFx/SpawnSound.play_sound()
	self.connect("position_changed", manager, "update_position")
	update_map(initial_region_type, initial_region_number)
	self.position = tilemap.map_to_world(get_map_position())

func _process(delta):
	_update_animation()

func get_gcoords():
	return global_position

func get_map_position():
	return tilemap.to_global(tilemap.world_to_map(position))

func can_move():
	return move_tick_timer.is_stopped()

func get_character_speed():
	return move_tick_timer.wait_time

func _get_animation_ref():
	var movement_state = "idle" if move_tick_timer.is_stopped() else "walk"

	var direction_string
	if direction == UP:
		direction_string = "up"
	elif direction == RIGHT:
		direction_string = "right"
	elif direction == DOWN:
		direction_string = "down"
	else:
		direction_string = "left"
	
	return movement_state + "_" + direction_string

func _update_animation():
	var animation = _get_animation_ref()
	
	if $Sprite.animation != animation:
		$Sprite.animation = animation

func move(to_direction):
	move_to(global_position + to_direction)

func move_to(gcoord):
	print("mt ", get_map_position(), " ", destination_tile, " ", can_move(), " ")
	if not Globals.can_interact:
		return
	if global_position() != get_map_position and can_move() and region.isNavigable(destination_tile):
		if region.tilemap.get_cellv(get_map_position()) == Globals.WALKABLE.DOCK && region.tilemap.get_cellv(destination_tile) == Globals.WALKABLE.NO:
			var done = false
			print("in")
			for r in $"../StaticAreas".get_children():
				var local_coords = r.to_local(destination_tile)
				if (r.isNavigable(r.tilemap.map_to_world(local_coords))):
					characters.character_areas[self] = r
					get_parent().remove_child(self)
					r.characters.call_deferred("add_child", self)
					done = true
					break
			if !done:
				for r in $"../MobileAreas".get_children():
					var local_coords = r.to_local(destination_tile)
					if (r.isNavigable(r.tilemap.map_to_world(local_coords))):
						characters.character_areas[self] = r
						get_parent().remove_child(self)
						r.characters.call_deferred("add_child", self)
						break
			print("rep")
		
		direction = destination_tile - get_map_position()
		move_tick_timer.start()
		$SoundFx/WalkSound.play_sound()
		var destination = tilemap.map_to_world(tilemap.to_local(gcoord))
		emit_signal("position_changed", self, destination_tile)
		$Tween.interpolate_property(
			self, "position", self.position, destination, get_character_speed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
		
		var current_map = characters.character_areas[self]
		var current_wall_tile = current_map.wall_map.get_cell(destination_tile.x, destination_tile.y + 1)
		self.z_index = 1 if current_wall_tile != 10 else 0
