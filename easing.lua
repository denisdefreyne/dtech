local Easing = {}

-- NOTE: This list of easing functions is incomplete. Expand when/if needed.

Easing.linear = function(frac)
    return frac
end

Easing.bounceOut = function(frac)
    local n1 = 7.5625
    local d1 = 2.75

    if frac < 1 / d1 then
        return n1 * frac * frac
    elseif frac < 2 / d1 then
        frac = frac - 1.5 / d1
        return n1 * frac * frac + 0.75
    elseif frac < 2.5 / d1 then
        frac = frac - 2.25 / d1
        return n1 * frac * frac + 0.9375
    else
        frac = frac - 2.625 / d1
        return n1 * frac * frac + 0.984375
    end
end

Easing.elasticOut = function(frac)
    local c4 = (2 * math.pi) / 3

    if frac == 0 then
        return 0
    elseif frac == 1 then
        return 1
    else
        return math.pow(2, -10 * frac) * math.sin((frac * 10 - 0.75) * c4) + 1
    end
end

Easing.backOut = function(frac)
    local c1 = 1.70158
    local c3 = c1 + 1

    return 1 + c3 * math.pow(frac - 1, 3) + c1 * math.pow(frac - 1, 2)
end

Easing.quadIn = function(frac)
    return frac * frac
end

Easing.quadOut = function(frac)
    local a = (1 - frac)
    return 1 - a * a
end

Easing.cubicIn = function(frac)
    return frac * frac * frac
end

Easing.cubicOut = function(frac)
    local a = (1 - frac)
    return 1 - a * a * a
end

Easing.quartIn = function(frac)
    local m = frac * frac
    return m * m
end

Easing.quartOut = function(frac)
    local a = (1 - frac)
    local m = a * a
    return 1 - m * m
end

Easing.quintIn = function(frac)
    local m = frac * frac
    return m * m * frac
end

Easing.quintOut = function(frac)
    local a = (1 - frac)
    local m = a * a
    return 1 - m * m * a
end

return Easing
