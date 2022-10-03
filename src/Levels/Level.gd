signal level_failed

extends Node

onready var hud = $UI/HUD
onready var map = get_node("Map")
onready var player = $Map/Characters/Player
onready var doors_manager = $Map/Doors
onready var camera: Camera2D = $Map/Characters/Player/Camera2D
onready var characters = $Map/Characters

onready var pulse = $"%VisualPulse"
onready var timer = $"%Timer"
onready var music_timer = $"%MusicTimer"
onready var level_number = $"%LevelNumber"
onready var level_name = $"%LevelName"
onready var level_card = $"%LevelCard"
onready var dialog = $"%Dialog"

var level_names = ["Alpha Condor", "Busser Force One"]

var difficulty
var current_level_number = 0
var skip_level_intro = false

func init(level_number, skip_level_intro):
	self.skip_level_intro = Globals.SKIP_LEVEL_INTRO or skip_level_intro
	difficulty = level_number
	yield(get_node("UI/HUD"), "ready")
	get_node("UI/HUD").set_level_decoration(level_number, level_names[level_number])
	current_level_number = level_number

func _start_level():
	Globals.can_interact = true
	
	if not skip_level_intro:
		if current_level_number == 0:
			dialog.open_dialog(["Welcome to space.", "The space cat overlord says: \"Find all my kittens.\""])
	
	var tween := create_tween()
	tween.tween_property(hud, "modulate:a", 1.0, 0.5)
	
	# sync timer with music
	var current_player: AudioStreamPlayer = get_viewport().get_parent().get_parent().current_player
	var music_diff = 1.0 - fmod(current_player.get_playback_position(), 1.0)
	music_timer.start(music_diff)

func _ready():
	Globals.can_interact = false
	
	pulse.material.set_shader_param("time", 0.0)
	pulse.material.set_shader_param("intensity", 0.0)
	pulse.material.set_shader_param("enabled", false)
	
	level_number.text = "LEVEL %s //////////" % str(current_level_number + 1).pad_zeros(3)
	level_name.text = level_names[current_level_number]
	level_card.modulate.a = 0.0
	
	var tween := create_tween()
	var tween2 := create_tween()
	
	if skip_level_intro:
		get_tree().call_group("ceiling_tilemaps", "animate_hide")
		self._start_level()
		return
	
	camera.offset = map.get_map_center_relative_to_player()
	camera.zoom = Vector2(3.0, 3.0)
	hud.modulate.a = 0.0
	
	get_tree().call_group("ceiling_tilemaps", "animate_show")
	
	tween.tween_interval(0.5)
	tween.tween_property(level_card, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.0)
	tween.tween_property(level_card, "modulate:a", 0.0, 0.5)
	
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "offset", Vector2(0.0, 0.0), 3.0)
	tween.parallel().tween_property(camera, "zoom", Vector2(0.5, 0.5), 3.0)
	tween.tween_callback(self, "_start_level")
	
	tween2.tween_interval(5.5)
	tween2.tween_callback(get_tree(), "call_group", ["ceiling_tilemaps", "animate_hide"])

func _process(delta):
	pulse.material.set_shader_param("time", timer.wait_time - timer.time_left)
	pulse.material.set_shader_param("intensity", 1.0 - timer.time_left / timer.wait_time)

func _on_Timer_timeout():
	pulse.material.set_shader_param("enabled", true)
	trigger_calamity()

enum Calamities {
	LIGHTS_OFF
	ROOM_ALERT
	CLOSE_DOOR
	SPAWN_MONSTER
}

func trigger_calamity():
	var player_region = characters.character_areas.get(player)
	var calamity = randi()%len(Calamities)
	if calamity == Calamities.LIGHTS_OFF:
		print('light')
		map.lights_off()
	elif calamity == Calamities.ROOM_ALERT:
		print('room alert')
		map.room_alert(player_region)
	elif calamity == Calamities.CLOSE_DOOR:
		print('door')
		map.close_doors()
	elif calamity == Calamities.SPAWN_MONSTER:
		map.spawn_monster()
		print('spawn monster')

func _on_MusicTimer_timeout():
	timer.start()

func level_failed():
	emit_signal("level_failed")
