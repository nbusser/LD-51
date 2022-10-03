extends TileMap


func animate_show():
	self.modulate.a = 1.0

func animate_hide():
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
