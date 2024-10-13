shader_type canvas_item;
render_mode blend_add;

uniform vec4 color: source_color;
uniform vec4 color2: source_color;
uniform vec4 color3: source_color;
uniform float time;
uniform float intensity = 0.0;
uniform bool enabled = false;

void fragment() {
	if (!enabled)
		COLOR = color;
	else if (time > 1.0)
		COLOR = mix(color, color2, pow(intensity, 3.0));
	else
		COLOR = color3;
	COLOR.a *= texture(TEXTURE, UV).a * pow(max(0, mod(time, 1.0) * -2.0 + 1.0), 3.0);
}
