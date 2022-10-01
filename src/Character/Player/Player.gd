signal cat_saved(pos)

extends Character

var interactible = null

func _init().("../../../"):
	pass

func _ready():
	map = get_node("../../../")
	self.connect("cat_saved", map, "save_cat")

func _process(delta):
	var direction := Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	# No diagonal move
	if(direction.x != 0 and direction.y != 0):
		direction.y = 0
	if direction != Vector2.ZERO:
		move(direction)

	if(Input.get_action_strength("ui_select")):
		print('TODO: interract with collided object')

func _on_Tween_tween_completed(hey, useless):
	if (map.get_node("Navigation2D/Items").get_cellv(get_map_position()) == Globals.CATS.CAT):
		emit_signal("cat_saved", get_map_position())

func _on_InteractZone_area_entered(area):
	interactible = area

func _on_InteractZone_area_exited(area):
	if interactible == area:
		interactible = null
