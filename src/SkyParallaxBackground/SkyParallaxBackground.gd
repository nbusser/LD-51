extends ParallaxBackground

@export var follow_mouse: bool = false

func _update_parallax(duration: float):
	if follow_mouse:
		var tween = create_tween()
		tween.tween_property(self, "scroll_offset", -get_viewport().get_mouse_position(), duration)
		self.scale = Vector2(2, 2)
		self.scroll_base_scale = Vector2(0.5, 0.5)

func _ready():
	self._update_parallax(0)
	

func _physics_process(delta: float):
	self._update_parallax(1)
	self.scroll_base_offset += Vector2(delta, delta) * 200 * self.scroll_base_scale
