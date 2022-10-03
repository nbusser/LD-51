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

enum TILE_TYPES {
	WALL = 0,
	GROUND = 20,
	DOOR_OPEN_H = 17,
	DOOR_CLOSED_H = 18
	DOOR_OPEN_V = 21,
	DOOR_CLOSED_V = 20,
}

enum WALKABLE {
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
