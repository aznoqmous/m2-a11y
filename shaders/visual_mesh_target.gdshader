shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;
uniform sampler2D noise: repeat_enable;
uniform float trail_power: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float borealis_power: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec3 borealis_color: source_color;
uniform float borealis_frequency : hint_range(0.0, 100.0, 0.1) = 10.0;
void vertex() {
}

vec4 shift_hue(in vec4 color, in float shift) {
	// The unit gray vector in RGB color space.
	vec3 gray = vec3(0.57735);
	// Project color onto gray axis.
	vec3 projection = gray * dot(gray, color.rgb);
	// Vector from gray axis to original color.
	vec3 U = color.rgb - projection;
	// Vector perpendicular to gray axis and U.
	vec3 V = cross(gray, U);
	// Rotate U and V around the gray axis.
	vec3 shifted = U * cos(shift * 2.0 * PI) + V * sin(shift * 2.0 * PI) + projection;
	return vec4(shifted, color.a);
}

void fragment() {
	vec4 screen_color = texture(screen_texture, UV);
	COLOR = screen_color * clamp(1.0 - 1.0 / (clamp(trail_power, 0.1, 1.0) * 100.0), 0.1, 1.0);
	vec4 borealis = texture(screen_texture,
		UV 
		+ vec2(0.01, 0.0)) * 0.1 * pow(texture(noise, texture(noise, UV * vec2(1.0, 2.0) / 5.0 - vec2(TIME * 0.01), 1.0).r + UV + vec2(TIME / 10.0, sin(UV.x * borealis_frequency + TIME / 10.0))).r,
		10.0 * borealis_power
	);
	//borealis.rgb = borealis_color * borealis.b;
	//borealis.b *= mod(TIME, 1.0);
	borealis = shift_hue(borealis, mod(TIME, 1.0) * 0.2);
	COLOR += borealis * clamp(length(COLOR.rgb) / borealis_power, 0.0, 1.0);
}
