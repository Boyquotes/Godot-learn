shader_type spatial;
render_mode depth_draw_alpha_prepass, blend_mix, specular_disabled, cull_back, world_vertex_coords, diffuse_lambert, vertex_lighting;

uniform sampler2D texture_albedo;
uniform float fresnel_range : hint_range(0,10) = 1.0;
uniform float fresnel_power : hint_range(0,10) = 1.0;
varying float alpha;

void vertex() {
	alpha = COLOR.a;
}

void fragment() {
	float fresnel = fresnel_power * pow(1.0 - dot(NORMAL, VIEW),fresnel_range);
	ALBEDO = texture(texture_albedo, UV).rgb + fresnel;
	ALPHA = texture(texture_albedo, UV).a * alpha;
}