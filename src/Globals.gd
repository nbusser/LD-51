extends Node

const SAMPLE_GLOBAL_VARIABLE = 1
const SCENE_TRANSITION_DURATION: float = 0.5

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
	DOOR_OPEN = 13,
	DOOR_CLOSED = 15,
}

enum ITEMS {
	CAT = 9
}
