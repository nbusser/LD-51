extends Control

signal next_level

var level_number
var pressed = false

@onready var level_label = $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer/LevelNumber

func _ready():
	assert(level_number != null, "init must be called before creating EndLevel scene")
	level_label.text = str(level_number + 1)

func init(new_level_number):
	self.level_number = new_level_number

func _on_NextLevelButton_pressed():
	if !pressed:
		pressed = true
		emit_signal("next_level")
