shader_type canvas_item;
uniform vec2 draw_position;
uniform vec2 size;
uniform sampler2D ttexture: hint_screen_texture;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uvv = (vec2(UV.x, -UV.y) - vec2(0.5, -0.5)) * size;
	//COLOR = mix(vec4(vec3(distance(draw_position, uvv) / 100.0), 1.0), texture(TEXTURE, UV + vec2(1.0 / size.x, 0.0)), 0.9);
	COLOR = texture(TEXTURE, UV) * 0.9;
	//COLOR = vec4(UV.x, UV.y, 0, 1);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
