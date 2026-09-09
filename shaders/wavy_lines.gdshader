shader_type canvas_item;
uniform sampler2D existing_screen: hint_screen_texture, filter_linear_mipmap;
uniform float frequency = 60;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 new_uv = SCREEN_UV;
	new_uv.x += sin(new_uv.y * frequency  + TIME ) * 0.005;
	
	vec3 new_colors = textureLod(existing_screen, new_uv, 0.0).rgb;
	COLOR.rgb = new_colors;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
