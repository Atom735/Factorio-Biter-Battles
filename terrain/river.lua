local Noises = require 'utils.noises'
local DirectionVectors = require 'utils.direction_vectors'
local TerrainParams = require 'terrain.params'
local TerrainDebug = require 'terrain.debug'
local is_spawn_circle = require'terrain.spawn_circle'.contains

local table_insert = table.insert
local math_floor = math.floor
local math_abs = math.abs

local Public = {}

function Public.contains(surface, seed, direction, pos)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south
    local dv = DirectionVectors[direction]
    local outer_radius = TerrainParams.river.radius
    local outer_noise = TerrainParams.river.noise
    local curve_radius = TerrainParams.river.curve_factor
    local curve_noise = TerrainParams.river.curve_noise

    -- LuaFormatter off
    local tile_pos = {
        x = math_floor(pos.x) ,
        y = math_floor(pos.y),
    }
    pos = {
        x = tile_pos.x + 0.5,
        y = tile_pos.y + 0.5,
    }
    -- LuaFormatter on

    local outer_r = outer_radius
    -- Skip the chunk if it's far from the river
    local px = pos.x * dv.x + pos.y * dv.y
    if px < -48 then return false end
    local py = math_abs(pos.x * dv.y - pos.y * dv.x)
    if curve_radius > 0 then
        if curve_radius <= 1 then
            outer_r = outer_r + px * curve_radius
        else
            outer_r = outer_r + (px * px * (curve_radius - 1) * 0.01)
        end
    end
    if py > outer_r + 48 then return false end

    px = pos.x * dv.x + pos.y * dv.y
    -- skip the tile if we are on the other side of the ray
    if px < 0 then return false end
    py = math_abs(pos.x * dv.y - pos.y * dv.x)
    -- Skip the tile if it's far from the river
    if py > outer_r then return false end

    -- Skip spawan_circle tiles
    if is_spawn_circle(surface, seed, tile_pos) then return false end

    if outer_noise >= 1.0 then
        local noise = math_abs(Noises.river(tile_pos, seed))
        if curve_noise > 0 then noise = noise * (px * curve_noise * 0.01) end
        outer_r = outer_r - noise * outer_noise
    end
    return py <= outer_r

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
    local curve_radius = TerrainParams.river.curve_factor
    local curve_noise = TerrainParams.river.curve_noise

    local outer_r = outer_radius
    -- LuaFormatter off
    local pos = {x = left_top.x + 0.5, y = left_top.y + 0.5}
    -- LuaFormatter on

    -- Skip the chunk if it's far from the river
    local px = pos.x * dv.x + pos.y * dv.y
    if px < -48 then return end
    local py = math_abs(pos.x * dv.y - pos.y * dv.x)
    if curve_radius > 0 then
        if curve_radius <= 1 then
            outer_r = outer_r + px * curve_radius
        else
            outer_r = outer_r + (px * px * (curve_radius - 1) * 0.01)
        end
    end
    if py > outer_r + 48 then return end

    for y = 0, 31, 1 do
        for x = 0, 31, 1 do
            -- LuaFormatter off
            local tile_pos = {x = left_top.x + x, y = left_top.y + y}
            pos = {x = tile_pos.x + 0.5, y = tile_pos.y + 0.5}
            -- LuaFormatter on

            px = pos.x * dv.x + pos.y * dv.y
            -- skip the tile if we are on the other side of the ray
            if px < 0 then goto p_skip end
            py = math_abs(pos.x * dv.y - pos.y * dv.x)
            outer_r = outer_radius
            if curve_radius > 0 then
                if curve_radius <= 1 then
                    outer_r = outer_r + px * curve_radius
                else
                    outer_r = outer_r + (px * px * (curve_radius - 1) * 0.01)
                end
            end
            -- Skip the tile if it's far from the river
            if py > outer_r then goto p_skip end
            -- Skip spawan_circle tiles
            if is_spawn_circle(surface, seed, tile_pos) then goto p_skip end
            local outer_r2 = outer_r - outer_noise
            if outer_noise >= 1.0 then
                local noise = math_abs(Noises.river(tile_pos, seed))
                if curve_noise > 0 then noise = noise * (px * curve_noise * 0.01) end
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
