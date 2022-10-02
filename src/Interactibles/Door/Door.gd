signal open_door(pos)

extends Interactible

var _opened
var _pos

func _init().(Globals.Interactibles.DOOR):
	pass

func init(opened, pos):
	_opened = opened
	_pos = pos

func is_interactible():
	return not _opened

func change_state(new_state):
	_opened = new_state

func interact():
	change_state(true)
	emit_signal("open_door", _pos)

func get_interactible_type():
	return interactible_type
