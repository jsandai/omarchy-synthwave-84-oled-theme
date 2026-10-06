// Neon glow for Ghostty text: bright pixels spread a soft halo into the
// dark around them. Scoped to the terminal surface on purpose; a Hyprland
// screen_shader did the same over the whole output and posterized video.
//
// The halo is a blur with fixed, normalized weights, so a flat colour area
// gets back roughly its own colour instead of a gain. Screen blending keeps
// every channel below 1.0, which avoids the pink clipping on bright cyan.

const float STRENGTH = 0.55;  // halo intensity
const float RADIUS   = 2.0;   // inner ring radius in pixels; outer ring is 2x
const float WHITE    = 0.35;  // emission of unsaturated text relative to neon

vec3 emission(vec3 c) {
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    float chroma = mx - mn;
    // Continuous weights only: a hard gate is what made the old shader band.
    float bright = smoothstep(0.2, 0.8, mx);
    float neon = mix(WHITE, 1.0, smoothstep(0.0, 0.5, chroma));
    return c * bright * neon;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 px = 1.0 / iResolution.xy;
    vec4 base = texture(iChannel0, uv);

    vec3 halo = vec3(0.0);
    float total = 0.0;
    for (int i = 0; i < 8; i++) {
        float a = 6.28318 * float(i) / 8.0;
        vec2 dir = vec2(cos(a), sin(a));
        // The outer ring is offset half a step so the two rings interleave.
        vec2 dir2 = vec2(cos(a + 0.3927), sin(a + 0.3927));
        halo += emission(texture(iChannel0, uv + dir * RADIUS * px).rgb) * 0.6;
        halo += emission(texture(iChannel0, uv + dir2 * RADIUS * 2.0 * px).rgb) * 0.4;
        total += 1.0;
    }
    halo /= total;

    vec3 glow = halo * STRENGTH;
    fragColor = vec4(1.0 - (1.0 - base.rgb) * (1.0 - glow), base.a);
}
