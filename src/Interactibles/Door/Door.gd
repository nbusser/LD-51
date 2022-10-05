signal open_door(area, pos)
signal close_door(area, pos)

extends Interactible

var _opened
var _pos
var _region

func _init().(Globals.Interactibles.DOOR):
	pass

func init(region, opened, pos):
	_opened = opened
	_pos = pos
	_region = region

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
	$SoundFx/OpenSound.play_sound()
	emit_signal("open_door", _region, _pos)

func close():
	$SoundFx/CloseSound.play_sound()
	emit_signal("close_door", _region, _pos)

func get_interactible_type():
	return interactible_type

func is_calamitable():
	return true
