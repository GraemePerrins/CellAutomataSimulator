#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;    // Active grid screen size (W_active, H_active)
uniform vec2 u_grid_size;     // Grid dimensions in cells (cols, rows)
uniform float u_shape_type;   // 0.0 = Square/Rectangle, 1.0 = Circle
uniform float u_cell_padding; // Gap between cells (0.0 to 0.4)
uniform vec4 u_alive_color;   // Alive cell color (RGBA)
uniform vec4 u_dead_color;    // Dead/background cell color (RGBA)
uniform sampler2D u_grid_tex; // Cell grid texture

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / u_resolution;

    // Check bounds [0.0, 1.0]
    if (uv.x < 0.0 || uv.x >= 1.0 || uv.y < 0.0 || uv.y >= 1.0) {
        fragColor = u_dead_color;
        return;
    }

    vec2 cellCoord = floor(uv * u_grid_size);
    vec2 cellUV = fract(uv * u_grid_size);

    // Sample cell status from texture (texture coordinates at center of cell texel)
    vec4 texColor = texture(u_grid_tex, (cellCoord + 0.5) / u_grid_size);
    float cellVal = texColor.r; // 0.0 = dead, >0.0 = alive

    if (cellVal < 0.01) {
        fragColor = u_dead_color;
        return;
    }

    if (u_shape_type < 0.5) {
        // --- SQUARE / RECTANGLE MODE ---
        vec2 border = step(vec2(u_cell_padding), cellUV) * step(cellUV, vec2(1.0 - u_cell_padding));
        fragColor = mix(u_dead_color, u_alive_color, border.x * border.y);
    } else {
        // --- CIRCLE MODE (Strict 1:1 Euclidean Circle) ---
        float dist = length(cellUV - vec2(0.5));
        float radius = 0.5 - u_cell_padding;
        // 1-pixel anti-aliasing delta without requiring fwidth
        float delta = clamp(u_grid_size.x / u_resolution.x, 0.002, 0.08);
        float alpha = 1.0 - smoothstep(radius - delta, radius + delta, dist);
        fragColor = mix(u_dead_color, u_alive_color, clamp(alpha, 0.0, 1.0));
    }
}
