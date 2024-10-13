extends Control

var current_level_number = 0
var nb_coins = 0

var current_player
var current_scene : set = set_scene

@onready var music_players = $Musics.get_children()

@onready var main_menu = preload("res://src/MainMenu/MainMenu.tscn")
@onready var levels = [
	preload("res://src/Levels/Level1/Level1.tscn"),
	preload("res://src/Levels/Level2/Level2.tscn"),
	preload("res://src/Levels/Level3/Level3.tscn"),
	preload("res://src/Levels/Level4/Level4.tscn"),
]
@onready var change_level = preload("res://src/EndLevel/EndLevel.tscn")
@onready var credits = preload("res://src/Credits/Credits.tscn")
@onready var game_over = preload("res://src/GameOver/GameOver.tscn")

@onready var viewport = $"%MainViewport"
@onready var scene_transition = $SceneTransition

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_run_main_menu()

func _process(_delta):
	if Input.is_action_pressed("quit"):
		# get_tree().quit()
		pass

func _on_quit_game():
	get_tree().quit()

func _on_start_game():
	current_level_number = 0
	_load_level()

func _on_show_credits():
	_run_credits(true)

func _on_show_main_menu():
	_run_main_menu()

func _set_scene_callback(new_scene):
	if current_scene:
		viewport.remove_child(current_scene)
		current_scene.queue_free()
	current_scene = new_scene
	viewport.add_child(current_scene)
	
	var tween := create_tween()
	tween.tween_property(scene_transition, "modulate:a", 0.0, Globals.SCENE_TRANSITION_DURATION)

func set_scene(new_scene):
	var tween := create_tween()
	if current_scene:
		tween.tween_property(scene_transition, "modulate:a", 1.0, Globals.SCENE_TRANSITION_DURATION)
	tween.tween_callback(Callable(self, "_set_scene_callback").bind(new_scene))

func _load_level(skip_level_intro = false):
	var scene = levels[current_level_number].instantiate()
	scene.init(current_level_number, skip_level_intro)
	scene.get_node("UI/HUD").connect("level_done", Callable(self, "_on_end_of_level"))
	scene.connect("level_failed", Callable(self, "_on_game_over"))
	self.current_scene = scene

func _on_end_of_level():
	if current_level_number + 1 >= levels.size():
		_run_credits(false)
	else:
		_load_end_level()

func _on_game_over():
	var scene = game_over.instantiate()
	scene.connect("restart", Callable(self, "_on_restart_level"))
	scene.connect("main_menu", Callable(self, "_on_show_main_menu"))
	self.current_scene = scene

func _on_restart_level():
	_load_level(true)

func _on_restart_select_level():
	_load_end_level()

func _load_end_level():
	var scene = change_level.instantiate()
	scene.init(current_level_number)
	scene.connect("next_level", Callable(self, "_on_next_level"))
	self.current_scene = scene

func _on_next_level():
	current_level_number += 1
	change_music_track(music_players[current_level_number % len(music_players)])
	_load_level()

func _run_credits(can_go_back):
	var scene = credits.instantiate()
	scene.set_back(can_go_back)
	if can_go_back:
		scene.connect("back", Callable(self, "_on_show_main_menu"))
	self.current_scene = scene

func _run_main_menu():
	var scene = main_menu.instantiate()
	change_music_track(music_players[0])
	scene.connect("start_game", Callable(self, "_on_start_game"))
	scene.connect("quit_game", Callable(self, "_on_quit_game"))
	scene.connect("show_credits", Callable(self, "_on_show_credits"))
	self.current_scene = scene

func change_music_track(new_player):
	if current_player != new_player:
		for mp in music_players:
			mp.stop()
		new_player.play()
		current_player = new_player
