extends Node2D
class_name Interactible

var interactible_type setget , get_interactible_type

func _init(_interactible_type):
	interactible_type = _interactible_type

func is_interactible():
	print('ERROR: "is_interactible" function not implemented by inherited class')

func interact():
	print('ERROR: "interact" function not implemented by inherited class')

func get_interactible_type():
	return interactible_type

func is_calamitable():
	print('ERROR: "is_calamitable" function not implemented by inherited class')
