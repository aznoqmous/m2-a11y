shader_type canvas_item;
uniform sampler2D existing_screen: hint_screen_texture, filter_linear_mipmap;
uniform float frequency = 60;
uniform float speed = 10.0;
uniform float amplitude = 1.0;
uniform sampler2D tex: repeat_enable;
uniform sampler2D gradient;
uniform float texSpeedx = 0.1;
uniform float texSpeedy = 0.1;


void vertex() {
	VERTEX.y += sin(VERTEX.x * frequency + TIME * speed) * amplitude;
}

void fragment() {
	
	COLOR = texture(tex, UV + vec2(TIME * texSpeedy, TIME) + vec2(UV.x + TIME * texSpeedx)) * texture(gradient, UV);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
