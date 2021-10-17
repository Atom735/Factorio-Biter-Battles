local TerrainParams = require 'terrain.table'
local TerrainDebug = require 'terrain.debug'
local DirectionVectors = require 'utils.direction_vectors'

local math_floor = math.floor
local math_max = math.max
local math_min = math.min

local rocks = {'rock-huge', 'rock-big', 'rock-big', 'rock-big', 'sand-rock-big'}

local function generate_additional_rocks(surface, seed, direction)

    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south

    local silo_distance = TerrainParams.silo_distance
    local rocks_min_count = TerrainParams.rocks_min_count

    local random = game.create_random_generator(seed)
    local dv = DirectionVectors[direction]

    local sd = silo_distance * 1.5
    local sf = silo_distance * 0.75

    -- LuaFormatter off
    local points = {
        {x = (dv.x + dv.y)*sd, y = (dv.y - dv.x)*sd},
        {x = (dv.x - dv.y)*sd, y = (dv.y + dv.x)*sd},
        {x = (0.00 + dv.y)*sd, y = (0.00 - dv.x)*sd},
        {x = (0.00 - dv.y)*sd, y = (0.00 + dv.x)*sd},
    }
    -- LuaFormatter on
    local left_top = {x = 0.0, y = 0.0}
    local right_bottom = {x = 0.0, y = 0.0}
    for _, point in pairs(points) do
        left_top.x = math_min(left_top.x, point.x)
        left_top.y = math_min(left_top.y, point.y)
        right_bottom.x = math_max(right_bottom.x, point.x)
        right_bottom.y = math_max(right_bottom.y, point.y)
    end
    local count = surface.count_entities_filtered({
        type = 'simple-entity', area = {left_top = left_top, right_bottom = right_bottom},
    })
    if count >= rocks_min_count then return end
    local py = (1 + random(-0.5, 0.5)) * silo_distance
    local px = (random(-0.5, 0.5)) * silo_distance
    -- LuaFormatter off
    local position = {
        x = py * dv.x + px * dv.y,
        y = py * dv.y - px * dv.x,
    }
    -- LuaFormatter on
    for _ = 1, rocks_min_count - count do
        local name = rocks[math_floor(random(1.1, 5.9))]
        local pos = surface.find_non_colliding_position(name, {
            x = position.x + random(-sf, sf), y = position.y + random(-sf, sf),
        }, 16, 1)
        if pos then
            surface.create_entity({name = name, position = pos})
            TerrainDebug.entity_rock(surface, pos)
        end
    end
end


return generate_additional_rocks
