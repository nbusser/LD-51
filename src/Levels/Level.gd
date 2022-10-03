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
onready var lose_hp_cooldown = $"%LoseHpCooldown"
onready var health_filter = $"%HealthFilter"

var calamities_count = 0 

var level_names = ["Space Thing", "Busser Force One", "StarCats", "Meow Space Station", "N.E.U. 9", "Néo-Namur"]

var difficulty
var current_level_number = 0
var skip_level_intro = false
var health = 1.0
var dead = false

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
			dialog.open_dialog(["Welcome to space.", "The space cat overlord says: \"Find my kitten.\""])
		if current_level_number == 1:
			dialog.open_dialog(["The space cat overlord says: \"Now do it again.\""])
		if current_level_number == 2:
			dialog.open_dialog(["The space cat overlord says: \"I keep dropping my kittens all over the place.\""])
		yield(dialog, "close_dialog")
	
	var tween := create_tween()
	tween.tween_property(hud, "modulate:a", 1.0, 0.5)
	
	# sync timer with music
	var current_player: AudioStreamPlayer = get_viewport().get_parent().get_parent().current_player
	var music_diff = 1.0 - fmod(current_player.get_playback_position(), 1.0)
	music_timer.start(music_diff)
	
	if not skip_level_intro && current_level_number == 0:
		yield(get_tree().create_timer(3), "timeout")
		timer.stop()
		player.camera.add_trauma(0.2)
		yield(get_tree().create_timer(0.5), "timeout")
		dialog.open_dialog(["The evil bad guy says: \"HAHAHAHAHAHHAHAHAHAHAHA\"", "\"Did you really think it was going to be this easy?\"", "\"My calamity beam will make your life a living hell\""])
		yield(dialog, "close_dialog")
		$Map/StaticAreas/StaticRegion/Rooms/Room.blackout_room()
		player.camera.add_trauma(0.5)
		yield(get_tree().create_timer(1.5), "timeout")
		player.camera.add_trauma(0.2)
		yield(get_tree().create_timer(0.5), "timeout")
		dialog.open_dialog(["The evil bad guy says: \"Enjoy running into walls\""])
		yield(dialog, "close_dialog")
	elif not skip_level_intro && current_level_number == 1:
		yield(get_tree().create_timer(3), "timeout")
		player.camera.add_trauma(0.2)
		yield(get_tree().create_timer(0.5), "timeout")
		dialog.open_dialog(["The evil bad guy says: \"You will never escape the watchful eye of my half-blind tentacular minions!\""])
		yield(dialog, "close_dialog")

func _reset_ambiance_timer():
	$AmbianceSoundsTimer.wait_time = randi() % 15 + 5
	$AmbianceSoundsTimer.start()

func _ready():
	_reset_ambiance_timer()

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
	print("YOYO")
	
	tween.tween_callback(self, "_start_level")
	tween2.tween_interval(5.5)
	tween2.tween_callback(get_tree(), "call_group", ["ceiling_tilemaps", "animate_hide"])

func _process(delta):
	pulse.material.set_shader_param("time", timer.wait_time - timer.time_left)
	pulse.material.set_shader_param("intensity", 1.0 - timer.time_left / timer.wait_time)
	health = min(1.0, health + delta * 0.1)
	var tween := create_tween()
	tween.tween_property(health_filter, "modulate:a", max(0.0, 1.0 - health), 0.3)

func _on_Timer_timeout():
	pulse.material.set_shader_param("enabled", true)
	trigger_calamity()

enum Calamities {
	LIGHTS_OFF = 1
	CLOSE_DOOR = 2
	ROOM_ALERT = 3
	SPAWN_MONSTER = 4
}

enum CalamityPolicy {
	LOW_COST = 0
	HIGH_PRICED = 1
	RANDOM = 2
}

class CalamitySorter:
	static func sort_ascending(a, b):
		if a[1] < b[1]:
			return true
		return false
	static func sort_descending(a, b):
		if a[1] < b[1]:
			return false
		return true

const MAX_SEVERITY = 20
var severity_bank = 0

func _trigger_calamity(region, object):
	if object.is_in_group('lightbulb'):
		map.light_off(object)
	elif object.is_in_group('door'):
		map.switch_door(object)
	elif object.is_in_group('room'):
		map.room_alert(region, object)
	elif object.is_in_group('spawner'):
		map.spawn_monster(object)

func trigger_calamity():
	player.camera.add_trauma(0.5)
	
	var random_severity_income = randi() % 3 + 5
	severity_bank = min(severity_bank + random_severity_income, MAX_SEVERITY)

	var player_region = characters.character_areas.get(player)
	var calamities = map.get_all_possible_calamitables(player_region)
	
	var policy = randi() % len(CalamityPolicy)
	if policy == CalamityPolicy.LOW_COST:
		calamities.sort_custom(CalamitySorter, "sort_ascending")
	elif policy == CalamityPolicy.HIGH_PRICED:
		calamities.sort_custom(CalamitySorter, "sort_descending")
	else:
		calamities.shuffle()
	
	var i = 0
	while severity_bank > 0 and i < len(calamities):
		var calamity = calamities[i]
		var object = calamity[0]
		var cost = calamity[1]

		if severity_bank >= cost:
			severity_bank -= cost
			_trigger_calamity(player_region, object)

		i += 1

func _on_MusicTimer_timeout():
	timer.start()

func _is_player_invincible():
	return lose_hp_cooldown.time_left > 0.0 or dead

func lose_hp_player():
	if not _is_player_invincible():
		health -= 0.34
		camera.add_trauma(0.2)
		if health <= 0.0:
			health = 0.0
			kill_player()
		lose_hp_cooldown.start()

func kill_player():
	dead = true
	level_failed()

func level_failed():
	emit_signal("level_failed")

func _on_AmbianceSoundsTimer_timeout():
	$SoundFx/AmbianceSound.play_sound()
	_reset_ambiance_timer()
