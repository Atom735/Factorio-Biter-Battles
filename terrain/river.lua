local Noises = require 'utils.noises'
local DirectionVectors = require 'utils.direction_vectors'
local TerrainParams = require 'terrain.table'
local is_spawn_circle = require'terrain.spawn_circle'.contains

local table_insert = table.insert
local math_floor = math.floor
local math_abs = math.abs

local bb_config = require 'maps.biter_battles_v2.config'
local river_y_1 = bb_config.border_river_width * -1.5
local river_y_2 = bb_config.border_river_width * 1.5
local river_width_half = math_floor(bb_config.border_river_width * -0.5)

local Public = {}

function Public.contains(surface, seed, direction, pos)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south
    local dv = DirectionVectors[direction]

    if pos.y < river_y_1 then return false end
    if pos.y > river_y_2 then return false end
    if pos.y >= river_width_half - (math_abs(Noises.river(pos, seed)) * 4) then return true end
    return false
end


function Public.generate(surface, seed, direction, left_top)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south
    local dv = DirectionVectors[direction]

    local random = game.create_random_generator(seed)
    local tiles = {}
    local entities = {}
    local fish_chance = TerrainParams.fish_chance
    local outer_radius = TerrainParams.river.radius
    local outer_noise = TerrainParams.river.noise

    for x = 0, 31, 1 do
        for y = 0, 31, 1 do
            -- LuaFormatter off
            local tile_pos = {
                x = left_top.x + x,
                y = left_top.y + y,
            }
            local pos = {
                x = tile_pos.x + 0.5,
                y = tile_pos.y + 0.5,
            }
            local pos_y = {
                x = pos.x * dv.y,
                y = pos.y * (-dv.x),
            }
            -- LuaFormatter on
            local px = pos.x * dv.x + pos.y * dv.y
            if px < 0 then goto p_skip end
            if is_spawn_circle(surface, seed, tile_pos) then goto p_skip end
            local py = math_abs(pos.x * dv.y - pos.y * dv.x)
            if py > outer_radius then goto p_skip end

            local outer_r = outer_radius
            local outer_r2 = outer_radius - outer_noise
            if outer_noise >= 1.0 then
                local noise = math_abs(Noises.river({x = px, y = py}, seed))
                outer_r = outer_r - noise * outer_noise
                outer_r2 = outer_r - ((noise * outer_noise) * 2)
            end
            if py > outer_r then goto p_skip end

            local tile_name = 'deepwater'
            if py >= outer_r2 then tile_name = 'water' end
            table_insert(tiles, {name = tile_name, position = tile_pos})
            if tile_name == 'deepwater' then
                if random(0, 100) < fish_chance then table_insert(entities, pos) end
            end

            ::p_skip::
        end
    end

    surface.set_tiles(tiles, true)

    for i = 1, #entities, 1 do surface.create_entity({name = 'fish', position = entities[i]}) end
end


return Public
