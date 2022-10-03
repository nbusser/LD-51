signal cat_saved(pos)

extends Character

var interactible = null

onready var progress_bar = $"%ProgressBar"
onready var interaction_hint = $"%InteractionHint"
onready var camera = $"%Camera2D"

func handle_region_switch(old_region):
	if (old_region != null):
		self.disconnect("cat_saved", old_region, "save_cat")
	self.connect("cat_saved", region, "save_cat")

func _ready():
	interaction_hint.hide()

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
		if interactible.get_interactible_type() == Globals.Interactibles.LIGHT:
			$SoundFx/InteractLightSound.play_sound()
		$InteractTimer.start()
	elif is_interacting():
		if not interact_button_pressed or interactible == null or not interactible.is_interactible():
			$SoundFx/InteractLightSound.stop()
			$InteractTimer.stop()
	
	var gaze_angle := (get_viewport().get_mouse_position() - OS.get_window_size()/2).normalized()
	$Flashlight.rotation = gaze_angle.angle() - PI/2
	
	progress_bar.visible = is_interacting() or not can_interact()
	if is_interacting():
		progress_bar.value = 1.0 - $InteractTimer.time_left / $InteractTimer.wait_time
		progress_bar.theme_type_variation = ""
	elif not can_interact():
		progress_bar.value = $InteractCooldown.time_left / $InteractCooldown.wait_time
		progress_bar.theme_type_variation = "ProgressBar2"
	
	interaction_hint.visible = can_interact() and interactible and interactible.is_interactible()

func _on_Tween_tween_completed(hey, useless):
	if (region.get_node("TallMap").get_cellv(get_map_position()) == Globals.ITEMS.CAT):
		$SoundFx/CatSound.play_sound()
		emit_signal("cat_saved", get_map_position())

func _on_InteractZone_area_entered(area):
	interactible = area.get_parent()
	if interactible.get_interactible_type() == null:
		print('ERROR: interactible object does not extend Interactible class')

func _on_InteractZone_area_exited(area):
	if interactible == area.get_parent():
		interactible = null

func is_interacting():
	return $InteractTimer.time_left > 0

func can_interact():
	return not is_interacting() and $InteractCooldown.time_left == 0
	
func _on_InteractTimer_timeout():
	interactible.interact()
	$InteractCooldown.start()
