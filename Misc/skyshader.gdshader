shader_type sky;

uniform vec3 skyColour : source_color;
uniform vec3 skyHorizon : source_color;

void sky() {
	float col = clamp(EYEDIR.y / 0.05, 0.0, 1.0);
	vec3 finalColour = mix(skyHorizon,skyColour,col);
	COLOR = finalColour;
}
