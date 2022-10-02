signal cat_saved(pos)

extends Character

var interactible = null

func _init().("../../../"):
	pass

func _ready():
	map = get_node("../../../")
	self.connect("cat_saved", map, "save_cat")

func _process(_delta):
	var direction := Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	# No diagonal move
	if(direction.x != 0 and direction.y != 0):
		direction.y = 0
	if direction != Vector2.ZERO:
		move(direction)

	var interact_button_pressed = Input.get_action_strength("ui_select")

	if (
		can_interact()
		and interact_button_pressed
		and interactible != null
		and interactible.is_interactible()
	):
			$InteractTimer.start()
	elif is_interacting():
		if not interact_button_pressed or interactible == null or not interactible.is_interactible():
			$InteractTimer.stop()
	
	var gaze_angle := (get_viewport().get_mouse_position() - OS.get_window_size()/2).normalized()
	$Flashlight.rotation = gaze_angle.angle() - PI/2

func _on_Tween_tween_completed(hey, useless):
	if (map.get_node("Navigation2D/Items").get_cellv(get_map_position()) == Globals.ITEMS.CAT):
		emit_signal("cat_saved", get_map_position())

func _on_InteractZone_area_entered(area):
	interactible = area
	if interactible.get_interactible_type() == null:
		print('ERROR: interactible object does not extend Interactible class')

func _on_InteractZone_area_exited(area):
	if interactible == area:
		interactible = null

func is_interacting():
	return $InteractTimer.time_left > 0

func can_interact():
	return not is_interacting() and $InteractCooldown.time_left == 0
	
func _on_InteractTimer_timeout():
	interactible.interact()
	$InteractCooldown.start()
