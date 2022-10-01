extends Control

onready var level_label = $VBoxContainer/VBoxContainer/LevelNumber/LevelNumberValue
onready var coins_label = $VBoxContainer/VBoxContainer/CoinNumber/CoinNumberValue
var nb_coins_total = 0
var current_coins_count = 0

func set_level_number(level_number):
	level_label.text = str(level_number + 1)

func increment_coins():
	current_coins_count = current_coins_count + 1
	coins_label.text = str(current_coins_count) + "/" + str(nb_coins_total)

func set_coins(nb_coins):
	nb_coins_total = nb_coins
	coins_label.text = "0/" + str(nb_coins_total)
