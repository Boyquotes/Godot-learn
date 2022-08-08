shader_type spatial;
render_mode cull_back,depth_draw_always,specular_disabled,unshaded;

uniform vec4 emission : hint_color = vec4(1.0);
uniform float power : hint_range(0,10) = 2.0;

varying float alpha;

void vertex() {
	alpha = COLOR.a;
}

void fragment() {
	ALBEDO = emission.rgb * power;
	ALPHA = alpha;
}