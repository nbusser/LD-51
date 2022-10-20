extends Control

signal restart
signal main_menu


func _on_Restart_pressed():
	emit_signal("restart")

func _on_MainMenu_pressed():
	emit_signal("main_menu")
