extends Node2D

onready var hud = get_node("../UI/HUD")
onready var characters = $Characters
onready var player = $Characters/Player
onready var doors = $Doors

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

func lights_off():
	var calamitables = player.get_node("CalamitySensor").get_overlapping_areas()
	var lights = []
	for calamitable in calamitables:
		if(calamitable.is_calamitable() and calamitable.interactible_type == Globals.Interactibles.LIGHT):
			lights.append(calamitable)
	if len(lights) == 0:
		return
	lights[0].change_state(Globals.LightingState.OFF)

func close_doors():
	var calamitables = player.get_node("CalamitySensor").get_overlapping_areas()
	var doors = []
	for calamitable in calamitables:
		if(calamitable.is_calamitable() and calamitable.interactible_type == Globals.Interactibles.DOOR):
			doors.append(calamitable)
	if len(doors) == 0:
		return
	doors[0].close()

func room_alert(region):
	var player_room = region.rooms.locate_player()
	if (!player_room.is_in_alert() && randi()%2):
		_trigger_alert(region, player_room)
		return
	
	var alertable := []
	for room in region.rooms.get_children():
		if (!room.is_in_alert()):
			alertable.append(room)
	if (len(alertable) > 0):
		_trigger_alert(region, alertable[randi()%(len(alertable))])

func _trigger_alert(region, room):
	room.trigger_alert()
	for character in characters.get_children():
		if characters.character_areas.get(character) == region and not character.is_in_group("player"):
			character.receive_alert(room)

func spawn_monster():
	# TODO: create enemy
	# TODO: connect signal kill
	pass

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
