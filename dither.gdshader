shader_type canvas_item;

uniform float pixel = 1.0;
uniform sampler2D palette : filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float brightness_boost : hint_range(1.0, 3.0) = 1.3; 
uniform float shadow_softness : hint_range(2.0, 8.0) = 5.0;

// NEW: This captures the camera's orientation in the world
uniform vec2 camera_rotation = vec2(0.0, 0.0);
uniform float dither_movement_weight : hint_range(0.0, 50.0) = 15.0; // Controls how fast the pattern slides

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
    _color.rgb *= brightness_boost;
    
    vec4 color = _color * texture(palette, vec2(_color.r, 0.5));
    
    // NEW: Offset the dithering coordinate calculations using the camera's rotation values
    // We scale the camera rotation and use "int" matching so it snaps perfectly to the retro layout
    int offset_x = int(camera_rotation.y * dither_movement_weight);
    int offset_y = int(camera_rotation.x * dither_movement_weight);
    
    // Inject the offsets into the Bayer matrix selection
    float b = getbayer(abs(int(FRAGCOORD.x) + offset_x) % 4, abs(int(FRAGCOORD.y) + offset_y) % 4);
    
    vec3 noise = vec3(fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453));
    noise *= 0.1;
    noise.xy *= (b / 16.0) * 1.5;
    
    vec4 col_noise = color;
    col_noise.rgb += noise;
    
    vec4 post = col_noise * floor(col_noise * shadow_softness) / shadow_softness;
    
    COLOR = post;
}