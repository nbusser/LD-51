extends Node

const SAMPLE_GLOBAL_VARIABLE = 1
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
	DOOR_OPEN_H = 60,
	DOOR_CLOSED_H = 63
	DOOR_OPEN_V = 62,
	DOOR_CLOSED_V = 61,
}

enum WALKABLE {
	YES = 0,
	NO = -1
}

enum ITEMS {
	CAT = 11
}
