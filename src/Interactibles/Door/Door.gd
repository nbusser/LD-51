signal open_door(pos)
signal close_door(pos)

extends Interactible

var _opened
var _pos
var _area

func _init().(Globals.Interactibles.DOOR):
	pass

func init(area, opened, pos):
	_opened = opened
	_pos = pos
	_area = area

func is_interactible():
	return not _opened

func change_state(new_state):
	_opened = new_state

func interact():
	emit_signal("open_door", _pos)

func close():
	emit_signal("close_door", _pos)

func get_interactible_type():
	return interactible_type

func is_calamitable():
	return _opened
