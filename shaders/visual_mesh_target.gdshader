shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_enable;
uniform sampler2D noise: repeat_enable;

void vertex() {
}

void fragment() {
	COLOR = texture(screen_texture, UV) * 0.99;
	COLOR += vec4(1.0 - distance(sin(UV.x * 6.0 * cos(TIME) + UV.y * 5.0 * sin(TIME) + TIME * 2.0), texture(noise, UV).r) * 10.0);
	//COLOR += vec4(distance(texture(noise, UV + vec2(TIME)).r + sin(TIME), UV.y)) * 0.1;
}
