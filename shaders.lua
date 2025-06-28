local Shaders = {}

Shaders.monochromeLight = love.graphics.newShader [[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        vec4 texel = Texel(tex, texture_coords);

        float grey = 0.2125 * texel.r + 0.7154 * texel.g + 0.0721 * texel.b;
        grey = 1 - (1 - grey) / 5;

        return vec4(grey, grey, grey, texel.a) * color;
    }
]]

Shaders.dissolveTransition = love.graphics.newShader [[
    extern float progress;
    extern Image fromTexture;
    extern Image toTexture;

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        vec4 fromColor = Texel(fromTexture, texture_coords);
        vec4 toColor = Texel(toTexture, texture_coords);

        return mix(fromColor, toColor, progress) * color;
    }
]]

-- adapted from https://github.com/RNavega/ScreenWipeShader-Love/tree/master
Shaders.circleWipeTransitionIn = love.graphics.newShader [[
    uniform float progress;
    extern Image fromTexture;
    extern Image toTexture;

    uniform vec2 wipeCenter = vec2(.5, .5);
    uniform float maxRadius = 0.70710678118; // sqrt(2) / 2

    float cubicInOut(float t) {
      return t < 0.5
        ? 4.0 * t * t * t
        : 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
    }

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        float feather = 0.3;

        vec4 fromColor = Texel(fromTexture, texture_coords);
        vec4 toColor = Texel(toTexture, texture_coords);

        vec2 centerOffset = texture_coords - wipeCenter;
        centerOffset.y *= (love_ScreenSize.y / love_ScreenSize.x);

        float shiftedRadius = maxRadius * progress;
        float centerOffsetLength = length(centerOffset) + feather * (1 - progress);
        float alpha = smoothstep(shiftedRadius, shiftedRadius + feather, centerOffsetLength);

        return mix(fromColor, toColor, cubicInOut(1 - alpha)) * color;
    }
]]

-- adapted from https://github.com/RNavega/ScreenWipeShader-Love/tree/master
Shaders.circleWipeTransitionOut = love.graphics.newShader [[
    uniform float progress;
    extern Image fromTexture;
    extern Image toTexture;

    uniform vec2 wipeCenter = vec2(.5, .5);
    uniform float maxRadius = 0.70710678118; // sqrt(2) / 2

    float cubicInOut(float t) {
      return t < 0.5
        ? 4.0 * t * t * t
        : 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
    }

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        float feather = 0.3;

        vec4 fromColor = Texel(fromTexture, texture_coords);
        vec4 toColor = Texel(toTexture, texture_coords);

        vec2 centerOffset = texture_coords - wipeCenter;
        centerOffset.y *= (love_ScreenSize.y / love_ScreenSize.x);

        float shiftedRadius = maxRadius * (1 - progress);
        float centerOffsetLength = length(centerOffset) + feather * progress;
        float alpha = smoothstep(shiftedRadius, shiftedRadius + feather, centerOffsetLength);

        return mix(fromColor, toColor, cubicInOut(alpha)) * color;
    }
]]

Shaders.dotsTransition = love.graphics.newShader [[
    extern float progress;
    extern Image fromTexture;
    extern Image toTexture;

    uniform vec2 center = vec2(0, 0);

    uniform float numDots = 20.0;

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        vec4 fromColor = Texel(fromTexture, texture_coords);
        vec4 toColor = Texel(toTexture, texture_coords);

        bool nextImage = distance(
            fract(texture_coords * numDots),
            vec2(0.5, 0.5)) < (
            progress / distance(texture_coords, center)
        );

        return nextImage ? toColor : fromColor;
    }
]]

Shaders.pixelDissolveTransition = love.graphics.newShader [[
    extern float progress;
    extern Image fromTexture;
    extern Image toTexture;

    float random(in vec2 st) {
        return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
    }

    float lowResRandom(in vec2 st) {
        return random(floor(st.xy));
    }

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        vec4 fromColor = Texel(fromTexture, texture_coords);
        vec4 toColor = Texel(toTexture, texture_coords);

        float frac = 0;
        if (progress > lowResRandom(screen_coords / 10)) {
            frac = 1;
        }

        return mix(fromColor, toColor, frac) * color;
    }
]]

return Shaders
