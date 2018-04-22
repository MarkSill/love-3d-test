uniform mat4 view;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
	return view * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	color = vec4(1, 0, 0, 1);
	return color;
}
#endif
