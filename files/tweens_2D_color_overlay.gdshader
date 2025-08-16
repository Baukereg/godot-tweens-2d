shader_type canvas_item;

uniform vec4 color = vec4(1.0);
uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
    base.rgb = mix(base.rgb, color.rgb, amount);
    COLOR = base;
}
