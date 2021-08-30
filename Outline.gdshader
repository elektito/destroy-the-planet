/* 
Shader edited from the one at: https://godotshaders.com/shader/rainbow-outline/

Original credits:

Rainbow outline by @Farfalk and @ThePadDev, July 2021

Apply to canvas items with transparent backgrounds.
Check that there is sufficient transparent background space for the outline!

CC0 License (but citation is welcome <3)
*/

shader_type canvas_item;

uniform float line_thickness : hint_range(0, 25) = 1.0;    // thickness of the line

const float pi = 3.14159265;

float sinx(float x) {
	// a sine-like function with where the first half of the each sine wave 
	// has a different period than the second one.
	
	const float light = 1.0;
	const float dark = 0.1;
	x = mod(x, pi*(light + dark));
	if (x <= pi*light) {
		return sin(x/light);
	} else {
		return -sin((x + light*pi)/dark);
	}
}

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);
	
	float value = (sinx(TIME) + 1.0) / 2.0;
	vec4 animated_line_color = vec4(1.0, 1.0, 1.0 - value, 1.0);
	
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, animated_line_color, outline - color.a);
}