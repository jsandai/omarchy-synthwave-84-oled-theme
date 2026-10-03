#version 300 es
// Synthwave '84 selective bloom for Hyprland screen_shader.
// Neon colors (pink/cyan/yellow/green) bloom; black and white stay crisp.
// Black floor preserved at 0 so OLED pixels stay off.
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float STRENGTH = 0.28;   // bloom intensity — tune this
const float RADIUS   = 1.5;    // tap ring radius in px-ish units
const float GATE     = 0.18;   // chroma floor: below this a pixel emits no bloom
const int   TAPS     = 16;

// saturation * luminance, gated — only vivid neon pixels emit bloom
float neonness(vec3 c) {
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    float sat = mx - mn;               // chroma
    float lum = dot(c, vec3(0.299, 0.587, 0.114));
    float g = smoothstep(GATE, GATE + 0.15, sat);  // hard-ish threshold
    return sat * lum * g;
}

void main() {
    vec4 base = texture(tex, v_texcoord);
    vec2 px = vec2(RADIUS) / vec2(textureSize(tex, 0));

    vec3 bloom = vec3(0.0);
    float wsum = 0.0;
    for (int i = 0; i < TAPS; i++) {
        float a = 6.28318 * float(i) / float(TAPS);
        vec2 off = vec2(cos(a), sin(a)) * px;
        vec3 s = texture(tex, v_texcoord + off).rgb;
        float w = neonness(s);
        bloom += s * w;
        wsum += w;
    }
    // second, tighter ring for near-field glow
    for (int i = 0; i < TAPS; i++) {
        float a = 6.28318 * (float(i) + 0.5) / float(TAPS);
        vec2 off = vec2(cos(a), sin(a)) * px * 0.5;
        vec3 s = texture(tex, v_texcoord + off).rgb;
        float w = neonness(s);
        bloom += s * w;
        wsum += w;
    }
    bloom /= max(wsum, 1e-4);

    vec3 outc = base.rgb + bloom * STRENGTH;
    fragColor = vec4(clamp(outc, 0.0, 1.0), base.a);
}
