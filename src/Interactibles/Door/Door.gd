signal open_door(area, pos)
signal close_door(area, pos)

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
	return true

func change_state(new_state):
	_opened = new_state

func interact():
	if _opened:
		close()
	else:
		open()

func open():
	emit_signal("open_door", _area, _pos)

func close():
	emit_signal("close_door", _area, _pos)

func get_interactible_type():
	return interactible_type

func is_calamitable():
	return _opened
