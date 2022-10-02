shader_type canvas_item;
render_mode blend_add;

uniform vec4 color: hint_color;

float intensity() {
	return pow(max(0, mod(TIME, 1.0) * -2.0 + 1.0), 3.0);
}

void fragment() {
	COLOR = color;
	COLOR.a *= texture(TEXTURE, UV).a * intensity();
}
