shader_type canvas_item;

uniform float pixel = 1.0;
uniform sampler2D palette : filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// NEW: Control the brightness from the Inspector
uniform float brightness_boost : hint_range(1.0, 3.0) = 1.3; 
uniform float shadow_softness : hint_range(2.0, 8.0) = 5.0; // Higher = lighter shadows

const mat4 bayer = mat4(
    vec4(1.0,  9.0,  3.0, 11.0),
    vec4(13.0,  5.0, 15.0,  7.0),
    vec4(4.0, 12.0,  2.0, 10.0),
    vec4(16.0,  8.0, 14.0,  6.0)
);

float getbayer(int x, int y) {
    return bayer[x][y]; 
}

void fragment() {
    vec2 screen_size = vec2(textureSize(screen_texture, 0));
    vec2 pixelated_uv = floor(FRAGCOORD.xy / pixel) * pixel / screen_size;
    
    vec4 _color = texture(screen_texture, pixelated_uv);
    
    // TWEAK 1: Boost the incoming screen brightness before matching the palette
    _color.rgb *= brightness_boost;
    
    // Map to palette texture
    vec4 color = _color * texture(palette, vec2(_color.r, 0.5));
    
    float b = getbayer(int(FRAGCOORD.x) % 4, int(FRAGCOORD.y) % 4);
    
    vec3 noise = vec3(fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453));
    noise *= 0.1;
    noise.xy *= (b / 16.0) * 1.5;
    
    vec4 col_noise = color;
    col_noise.rgb += noise;
    
    // TWEAK 2: Softened the posterization (changed 4.0 to shadow_softness)
    // This allows more mid-tones and highlights through instead of crushing them to black
    vec4 post = col_noise * floor(col_noise * shadow_softness) / shadow_softness;
    
    COLOR = post;
}