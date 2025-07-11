shader_type spatial;

uniform vec3 lineColor: source_color;
uniform vec3 baseColor: source_color;
uniform vec2 resolution;
uniform float thickness;
uniform float zoom;


float DrawGrid(vec2 uv)
{
	vec2 grid_uv = cos(uv * TAU);
	return max(grid_uv.x, grid_uv.y);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment()
{
	// Called for every pixel the material is visible on.
	vec4 world =  INV_VIEW_MATRIX * vec4(VERTEX, 1);


	vec2 uv = world.xz;
	uv.x *= resolution.x / resolution.y;
	//uv += vec2(sin(TIME) * 0.4, cos(TIME) * 0.6);
	//uv = rotate(uv, TIME * 0.1);
	//float zoom = abs(sin(TIME * 0.5)) * 40.0;
	//float line_thickness = zoom * thickness / resolution.y;
	float l = smoothstep(1.0 - thickness, 1.0, DrawGrid(uv * zoom));
	vec3 color = mix(baseColor, lineColor, l);
	//COLOR = vec4(color * 1.0, 1.0);

	ALBEDO = mix(color, round(world.yyy), clamp(round(world.y), 0, 1));

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
