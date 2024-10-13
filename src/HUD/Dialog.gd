extends Control

signal close_dialog

@onready var text_label = $"%Text"
@onready var key_label = $"%KeyLabel"
var text_values: Array = []
var current_step: int = 0
var writing_text = false
var tween_text: Tween

func _ready():
	hide()
	var tween_blink := create_tween()
	tween_blink.set_loops()
	tween_blink.tween_property(key_label, "modulate:a", 0.0, 1.0)
	tween_blink.tween_property(key_label, "modulate:a", 1.0, 1.0)

func _finished_writing():
	writing_text = false
	tween_text.stop()
	text_label.visible_characters = -1
	key_label.show()

func _load_step(step: int):
	current_step = step
	key_label.hide()
	show()
	writing_text = true
	if tween_text:
		tween_text.kill()
	tween_text = create_tween()
	text_label.visible_characters = 0
	text_label.text = text_values[step]
	tween_text.tween_property(text_label, "visible_characters", text_label.text.length(), max(0.5, text_label.text.length() * 0.01))
	tween_text.tween_callback(Callable(self, "_finished_writing"))

func open_dialog(text: Array):
	get_tree().paused = true
	text_values = text
	_load_step(0)

func end_dialog():
	get_tree().paused = false
	hide()
	emit_signal("close_dialog")

func _unhandled_input(event):
	if visible and event is InputEventKey and event.keycode == KEY_SPACE and event.is_pressed():
		if writing_text:
			_finished_writing()
		elif current_step < text_values.size() - 1:
			_load_step(current_step + 1)
		else:
			end_dialog()
