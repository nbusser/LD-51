signal position_changed(character, new_position)

extends Node2D

class_name Character

onready var move_tick_timer = $MoveTick
onready var characters = $"../../../../Characters"

onready var manager = get_parent()

const UP = Vector2(0, -32)
const DOWN = Vector2(0, 32)
const LEFT = Vector2(-32, 0)
const RIGHT = Vector2(32, 0)

var direction = DOWN

var region = null

export var initial_region_type = Globals.REGION_TYPE.STATIC
export var initial_region_number = 0

func correct(x):
	return region.tilemap.map_to_world(region.tilemap.world_to_map(x))

func center():
	position = correct(position)

func handle_region_switch(_old_region):
	pass

func update_map(new_region):
	var old_region = region
	region = new_region
	handle_region_switch(old_region)

func _ready():
	# Waits for Game.gd to run randomize()
	yield(get_tree(), "idle_frame")
	$SoundFx/SpawnSound.play_sound()
	update_map(get_node("../.."))
	self.connect("position_changed", manager, "update_position")
	center()

func _process(_delta):
	_update_animation()

func get_tile(gcoords):
	return region.tilemap.world_to_map(region.tilemap.to_local(gcoords))

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

func map_to_same_tile(t1, t2):
	return ((t1 - t2).length() < 0.5)

func move_to(gcoords):
	if not Globals.can_interact:
		return
	if !map_to_same_tile(gcoords, self.global_position) and can_move() and region.isNavigable(gcoords):
		if region.tilemap.get_cellv(get_tile(global_position)) == Globals.WALKABLE.DOCK && region.tilemap.get_cellv(get_tile(gcoords)) == Globals.WALKABLE.NO:
			var done = false
			var old_gp = region.global_position
			for r in $"../../../../StaticAreas".get_children():
				if (r != region && r.isNavigable(gcoords)):
					get_parent().remove_child(self)
					r.get_node("Characters").add_child(self)
					done = true
					break
			if !done:
				for r in $"../../../../MobileAreas".get_children():
					if (r != region && r.isNavigable(gcoords)):
						get_parent().remove_child(self)
						r.get_node("Characters").add_child(self)
						done = true
						break
			update_map(self.get_node("../.."))
			var shift = old_gp - region.global_position
			position += shift
			assert(done, "ERROR: REPARENTING FAILURE")
		
		direction = gcoords - global_position
		move_tick_timer.start()
		$SoundFx/WalkSound.play_sound()
		var destination = region.tilemap.to_local(gcoords)
		$Tween.interpolate_property(
			self, "position", self.position, destination, get_character_speed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
		
		var destination_tile = region.tilemap.world_to_map(destination)
		var current_wall_tile = region.wall_map.get_cell(destination_tile.x, destination_tile.y + 1)
		self.z_index = 1 if current_wall_tile != 10 else 0
