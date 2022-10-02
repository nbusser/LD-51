signal level_done

extends Control

onready var level_label = $VBoxContainer/VBoxContainer/LevelNumber/LevelNumberValue
onready var counter_label = $"%Counter"
onready var total_label = $"%Total"
var total_coins_count = 0
var current_coins_count = 0

func set_level_decoration(level_number, level_name):
	level_label.text = str(level_number + 1) + ": " + level_name

func increment_coins():
	current_coins_count = current_coins_count + 1
	counter_label.text = str(current_coins_count).pad_zeros(2)
	total_label.text = "/" + str(total_coins_count).pad_zeros(2)
	if (current_coins_count == total_coins_count):
		emit_signal("level_done")

func set_coins(nb_coins):
	current_coins_count = 0
	total_coins_count = nb_coins
	counter_label.text = "00"
	total_label.text = "/" + str(total_coins_count).pad_zeros(2)
