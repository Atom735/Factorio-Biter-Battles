local TerrainParams = require 'terrain.table'
local Noises = require 'utils.noises'

local table_insert = table.insert
local math_abs = math.abs
local math_sqrt = math.sqrt
local math_floor = math.floor

local Public = {}

function Public.contains(surface, seed, pos)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed

    local outer_r = TerrainParams.outer_circle.radius
    local outer_noise = TerrainParams.outer_circle.noise

    if math_abs(pos.x) > outer_r or math_abs(pos.y) > outer_r then return false end

    local x = math_floor(pos.x)
    local y = math_floor(pos.y)
    if x < 0 and y < 0 then
        x = -x - 1
        y = -y - 1
    elseif x < 0 then
        x = y
        y = -math_floor(pos.x) - 1
    elseif y < 0 then
        x = -y - 1
        y = math_floor(pos.x)
    end
    local r = math_sqrt(x ^ 2 + y ^ 2)

    if r > outer_r then return false end
    if r <= outer_r - outer_noise then return true end

    if outer_noise >= 1.0 then
        local noise = math_abs(Noises.spawn_circle_radius({x = x, y = y}, seed))
        outer_r = outer_r - noise * outer_noise
    end

    return r <= outer_r
end


function Public.draw(surface, seed)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed

    local outer_radius = TerrainParams.outer_circle.radius
    local outer_noise = TerrainParams.outer_circle.noise
    local inner_radius = TerrainParams.inner_circle.radius
    local inner_sand = TerrainParams.inner_circle.sand
    local fish_chance = TerrainParams.fish_chance

    surface.request_to_generate_chunks({0, 0}, (outer_radius) / 32 + 1)
    surface.force_generate_chunk_requests()

    local random = game.create_random_generator(seed)
    local tiles = {}
    local entities = {}

    for y = 0, outer_radius, 1 do
        for x = 0, outer_radius, 1 do
            -- LuaFormatter off
            local pos_rb = {x = x+0.5, y = y+0.5}
            local pos_rt = {x = y+0.5, y =-x-0.5}
            local pos_lb = {x =-y-0.5, y = x+0.5}
            local pos_lt = {x =-x-0.5, y =-y-0.5}
            -- LuaFormatter on
            local outer_r = outer_radius
            local r = math_sqrt(x ^ 2 + y ^ 2)
            if r > outer_r then goto skip_tile end
            local outer_r2 = outer_radius - outer_noise
            local outer_r3 = inner_radius + outer_noise
            if outer_noise >= 1.0 then
                local noise = math_abs(Noises.spawn_circle_radius({x = x, y = y}, seed))
                outer_r = outer_r - noise * outer_noise
                outer_r2 = outer_r - ((noise * outer_noise) * 2)
                outer_r3 = inner_radius + ((noise * outer_noise) * 2)
            end
            if r <= outer_r then
                local tile_name = 'deepwater'
                if r >= outer_r2 or r <= outer_r3 then tile_name = 'water' end
                if r < inner_radius then
                    if r < inner_sand then
                        tile_name = 'sand-1'
                    else
                        tile_name = 'refined-concrete'
                    end
                end
                table_insert(tiles, {name = tile_name, position = pos_rb})
                table_insert(tiles, {name = tile_name, position = pos_rt})
                table_insert(tiles, {name = tile_name, position = pos_lb})
                table_insert(tiles, {name = tile_name, position = pos_lt})
                if tile_name == 'deepwater' then
                    if random(0, 100) < fish_chance then
                        table_insert(entities, pos_rb)
                        table_insert(entities, pos_rt)
                        table_insert(entities, pos_lb)
                        table_insert(entities, pos_lt)
                    end
                end
            end
            ::skip_tile::
        end
    end
    surface.set_tiles(tiles, true)

    for i = 1, #entities, 1 do surface.create_entity({name = 'fish', position = entities[i]}) end
end


return Public
