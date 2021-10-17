local enabled = require'terrain.params'.debug or false

local TerrainDebug = {}

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


local color_map = {
    {r = 0.0, g = 0.0, b = 0.0, a = 0.5}, {r = 0.0, g = 0.0, b = 1.0, a = 0.5}, {r = 0.0, g = 1.0, b = 1.0, a = 0.5},
    {r = 0.0, g = 1.0, b = 0.0, a = 0.5}, {r = 1.0, g = 1.0, b = 0.0, a = 0.5}, {r = 1.0, g = 0.0, b = 0.0, a = 0.5},
    {r = 1.0, g = 0.0, b = 1.0, a = 0.5}, {r = 1.0, g = 1.0, b = 1.0, a = 0.5},
}
local color_map_sz = #color_map

local function get_color(value)
    value = math_clamp(value, 0, 1)
    local cvalue = (value * (color_map_sz - 1)) + 1
    local floor = math_clamp(math_floor(cvalue), 1, color_map_sz)
    local p = math_clamp(cvalue - floor, 0.0, 1.0)
    local ceil = math_clamp(math_ceil(cvalue), 1, color_map_sz)
    return {
        r = math_clamp(color_map[floor].r * (1.0 - p) + color_map[ceil].r * p, 0.0, 1.0),
        g = math_clamp(color_map[floor].g * (1.0 - p) + color_map[ceil].g * p, 0.0, 1.0),
        b = math_clamp(color_map[floor].b * (1.0 - p) + color_map[ceil].b * p, 0.0, 1.0), a = 0.5,
    }
end


function TerrainDebug.entity(surface, pos, value, color, radius)
    -- LuaFormatter off
    rendering.draw_circle {
        color = color or get_color(value),
        surface = surface,
        radius = radius or 0.45,
        target  = {pos.x, pos.y},
        filled = true,
    }
    -- LuaFormatter on
end


function TerrainDebug.tile(surface, pos, value, color)

    pos = {x = math_floor(pos.x), y = math_floor(pos.y)}
    -- LuaFormatter off
    rendering.draw_line {
        color = color or get_color(value),
        surface = surface,
        from = {pos.x, pos.y},
        to = {pos.x+1, pos.y+1},
        width = 2,
    }
    -- LuaFormatter on
end


function TerrainDebug.tile2(surface, pos, value, color)
    pos = {x = math_floor(pos.x), y = math_floor(pos.y)}
    -- LuaFormatter off
    rendering.draw_line {
        color = color or get_color(value),
        surface = surface,
        from = {pos.x+1, pos.y},
        to = {pos.x, pos.y+1},
        width = 2,
    }
    -- LuaFormatter on
end


function TerrainDebug.tile_spawner(surface, pos)
    if not enabled then return end
    TerrainDebug.tile2(surface, pos, nil, {102, 8, 255, 200})
end


function TerrainDebug.tile_river(surface, pos)
    if not enabled then return end
    TerrainDebug.tile(surface, pos, nil, {8, 160, 255, 200})
end


function TerrainDebug.tile_spawn_ores(surface, pos)
    if not enabled then return end
    TerrainDebug.tile2(surface, pos, nil, {8, 255, 148, 200})
end


function TerrainDebug.tile_spawn_silo(surface, pos)
    if not enabled then return end
    TerrainDebug.tile(surface, pos, nil, {102, 8, 255, 200})
end


function TerrainDebug.entity_rock(surface, pos)
    if not enabled then return end
    TerrainDebug.entity(surface, pos, nil, {105, 77, 27, 200})
end


return TerrainDebug
