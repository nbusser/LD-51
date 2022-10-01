extends Node2D

onready var map = get_parent()
onready var game = map.get_parent()


func _ready():
	# Waits for Game.gd to run randomize()
	yield(get_tree(), "idle_frame")
	$SoundFx/SpawnSound.play_sound()

#func _process(delta):
#	pass
