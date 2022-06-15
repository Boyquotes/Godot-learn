shader_type spatial;
render_mode vertex_lighting,diffuse_lambert,cull_back,depth_draw_opaque,specular_disabled;

uniform sampler2D texture_albedo;
uniform float fresnel_range : hint_range(0,10) = 1.0;
uniform float fresnel_power : hint_range(0,10) = 1.0;

void fragment() {
	float fresnel = fresnel_power * pow(1.0 - dot(NORMAL, VIEW),fresnel_range);
	ALBEDO = texture(texture_albedo, UV).rgb + fresnel;
}