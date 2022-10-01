extends Character

func _init().("../../../"):
	pass

func _process(delta):
	var direction := Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	# No diagonal move
	if(direction.x != 0 and direction.y != 0):
		direction.y = 0
	
	if direction != Vector2.ZERO:
		move(direction)

func _on_Tween_tween_completed(hey, useless):
	if (map.get_node("Navigation2D/Items").get_cellv(get_map_position()) == Globals.CATS.CAT):
		print("miaou")
