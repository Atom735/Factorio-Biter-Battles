local TerrainDebug = {}

local color_map = {
    {r = 0.0, g = 0.0, b = 0.0, a = 0.5}, {r = 0.0, g = 0.0, b = 1.0, a = 0.5}, {r = 0.0, g = 1.0, b = 1.0, a = 0.5},
    {r = 0.0, g = 1.0, b = 0.0, a = 0.5}, {r = 1.0, g = 1.0, b = 0.0, a = 0.5}, {r = 1.0, g = 0.0, b = 0.0, a = 0.5},
    {r = 1.0, g = 0.0, b = 1.0, a = 0.5}, {r = 1.0, g = 1.0, b = 1.0, a = 0.5},
}

local math_floor = math.floor
local math_ceil = math.ceil

local function math_clamp(num, min, max)
    if num < min then
        return min
    elseif num > max then
        return max
    else
        return num
    end
end


function TerrainDebug.tile_debug_render(surface, pos, value)
    value = math_clamp(value, 0, 1)
    local csz = #color_map
    local cvalue = (value * (csz - 1)) + 1
    local floor = math_clamp(math_floor(cvalue), 1, csz)
    local p = math_clamp(cvalue - floor, 0.0, 1.0)
    local ceil = math_clamp(math_ceil(cvalue), 1, csz)
    local color = {
        r = math_clamp(color_map[floor].r * (1.0 - p) + color_map[ceil].r * p, 0.0, 1.0),
        g = math_clamp(color_map[floor].g * (1.0 - p) + color_map[ceil].g * p, 0.0, 1.0),
        b = math_clamp(color_map[floor].b * (1.0 - p) + color_map[ceil].b * p, 0.0, 1.0), a = 0.5,
    }
    -- -- LuaFormatter off
    rendering.draw_line {
        color = color,
        surface = surface,
        from = {pos.x, pos.y},
        to = {pos.x+1, pos.y+1},
        width = 2,
    }
    -- LuaFormatter on
end


return TerrainDebug
