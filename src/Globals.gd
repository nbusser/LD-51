extends Node

const SKIP_LEVEL_INTRO = true
const SCENE_TRANSITION_DURATION: float = 0.5

var can_interact = true

enum Interactibles {
	LIGHT
	DOOR
}

enum LightingState {
	ON
	ALERT
	OFF
}

enum DECORATION_TILES {
	VENT = 37
}

enum TILE_TYPES {
	WALL = 0,
	GROUND = 20,
	DOOR_OPEN_H = 17,
	DOOR_CLOSED_H = 18
	DOOR_OPEN_V = 21,
	DOOR_CLOSED_V = 20,
}

enum WALKABLE {
	DOCK = 1,
	YES = 0,
	NO = -1
}

enum ITEMS {
	CAT = 11
}

enum REGION_TYPE {
	STATIC,
	MOBILE
}

func GET_REGION_INFOS(region):
	var region_type_node = region.get_node("../")
	var region_type
	var region_number

	if region_type_node.get_name() == "StaticAreas":
		region_type = Globals.REGION_TYPE.STATIC
	else:
		region_type = Globals.REGION_TYPE.MOBILE
	region_number = region.get_index()
	
	return [region_type, region_number]
