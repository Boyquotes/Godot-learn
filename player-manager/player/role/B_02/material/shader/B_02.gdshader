shader_type spatial;

//uniform float _rim_size : hint_range(0,8) = 5.0;
uniform float _glossiness : hint_range(0, 5) = 0.1;

uniform sampler2D texture : hint_albedo;
uniform vec4 base_color : hint_color = vec4(1, 1, 1, 1);

void fragment() {
 vec3 temp_albedo = texture(texture, UV.xy).rgb;

 ALBEDO = temp_albedo * base_color.rgb;
}


void light() {
        
 //diffuse
 float NdotL = clamp(dot(NORMAL, LIGHT), 0, 1) * ATTENUATION.x;

 //specular
 vec3 H = normalize(VIEW + LIGHT);
 float NdotH = clamp(dot(NORMAL, H), 0.0, 1.0) * ATTENUATION.x;
 float specular = pow(NdotH, 1.0 / _glossiness);

 //rim 
 //float rimDot = clamp(dot(VIEW, NORMAL), 0.0, 1.0);
 //float rim = pow(1.0 - rimDot, _rim_size);
        
 DIFFUSE_LIGHT += ALBEDO.rgb * LIGHT_COLOR * (NdotL + specular);

}