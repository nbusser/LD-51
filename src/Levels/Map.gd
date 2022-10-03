extends Node2D

onready var hud = get_node("../UI/HUD")
onready var characters = $Characters
onready var player = $Characters/Player
onready var doors = $Doors
onready var enemy = preload("res://src/Character/Enemy/Enemy.tscn")

var current_region_type = Globals.REGION_TYPE.STATIC
var current_region = 0

var door_cells = null

func switch_region(new_region_type, new_number):
	current_region_type = new_region_type
	current_region = new_number
	var root
	if current_region_type == Globals.REGION_TYPE.STATIC:
		root = $StaticAreas.get_children()[new_number]
	else:
		root = $MobileAreas.get_children()[new_number]

func _ready():
	switch_region(Globals.REGION_TYPE.STATIC, 0)
	var cats_count = 0
	for s_area in self.get_node("StaticAreas").get_children():
		cats_count += s_area.get_node("TallMap").get_used_cells_by_id(Globals.ITEMS.CAT).size()
	for m_area in self.get_node("MobileAreas").get_children():
		cats_count += m_area.get_node("TallMap").get_used_cells_by_id(Globals.ITEMS.CAT).size()
	hud.set_coins(cats_count)

func switch_random_door():
	doors.switch_random_door()
	
func get_all_calamitable_lights_in_room(room, cost=1):
	var lights = []
	for light in room.get_node("LightBulbs").get_children():
		if light.is_calamitable():
			lights.append([light, cost])
	return lights

func get_all_possible_calamitables(region):
	# Gather all calamitables
	var player_room = region.rooms.locate_player()

	var calamitables = []
	
	calamitables += get_all_calamitable_lights_in_room(player_room, 2)
	if not player_room.is_in_alert():
		calamitables.append([player_room, 5])

	for room in region.rooms.get_neighbours(player_room):
		calamitables += get_all_calamitable_lights_in_room(room)
		if not room.is_in_alert():
			calamitables.append([room, 4])


	var close_calamitables = player.get_node("CalamitySensor").get_overlapping_areas()
	for calamitable in close_calamitables:
		if calamitable.is_in_group("interactible"):
			calamitable = calamitable.get_parent()
			if calamitable.is_calamitable(): 
				if calamitable.interactible_type == Globals.Interactibles.DOOR:
					calamitables.append([calamitable, 2])
		elif calamitable.is_in_group("spawner"):
			calamitables.append([calamitable, 8])

	return calamitables

func light_off(light):
	light.change_state(Globals.LightingState.OFF)

func switch_door(door):
	door.interact()

func room_alert(region, room):
	room.trigger_alert()
	for character in characters.get_children():
		if characters.character_areas.get(character) == region and not character.is_in_group("player"):
			character.receive_alert(room)

func spawn_monster(spawner):
	var region = spawner.get_parent().get_parent()
	var region_infos = Globals.GET_REGION_INFOS(region)
	var region_type = region_infos[0]
	var region_number = region_infos[1]
	var pos = region.wall_deco_map.world_to_map(spawner.global_position)
	
	var mob = enemy.instance()
	$Characters.add_character(mob, region_type, region_number, region, spawner.global_position, pos)
	spawner.queue_free()

func get_map_center_relative_to_player() -> Vector2:
	var bounds = null
	for s_area in self.get_node("StaticAreas").get_children():
		if (bounds == null):
			bounds = s_area.calculate_bounds()
		else:
			bounds = bounds.merge(s_area.calculate_bounds())
	for m_area in self.get_node("MobileAreas").get_children():
		bounds = bounds.merge(m_area.calculate_bounds())
	return bounds.get_center() - player.position

func kill_player():
	# TODO: kill player
	$"../".level_failed()
