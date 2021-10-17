local TerrainParams = require 'terrain.table'
local Noises = require 'utils.noises'
local TerrainDebug = require 'terrain.debug'
local DirectionVectors = require 'utils.direction_vectors'
local Functions = require 'maps.biter_battles_v2.functions'
local get_replacement_tile_name = require'terrain.utils'.get_replacement_tile_name

local table_insert = table.insert
local math_floor = math.floor
local math_abs = math.abs
local math_sqrt = math.sqrt

local function generate_silo(surface, seed, direction, force)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south
    force = force or game.forces.player

    local silo_distance = TerrainParams.silo_distance
    local silo_safe_area = TerrainParams.silo_safe_area

    local random = game.create_random_generator(seed)
    local origin_offset = random(-0.75, 0.75) * silo_distance
    local dv = DirectionVectors[direction]

    -- LuaFormatter off
    local pos = {
        x = math_floor (dv.x * silo_distance + dv.y * origin_offset + 0.5),
        y = math_floor (dv.y * silo_distance - dv.x * origin_offset + 0.5),
    }
    -- LuaFormatter on
    surface.request_to_generate_chunks(pos, (9 + silo_safe_area) / 32 + 1)
    surface.force_generate_chunk_requests()

    -- local tiles = {}
    -- for x = 0, 64, 1 do
    --     for y = 0, 64, 1 do
    --         local tile_pos = {x = x + pos.x - 32, y = y + pos.y - 32}
    --         table_insert(tiles, {name = 'water', position = tile_pos})
    --     end
    -- end
    -- surface.set_tiles(tiles)

    local tiles = {}
    -- prepare safe area
    local ssa = silo_safe_area + 9
    for y = 0, ssa, 1 do
        for x = 0, ssa, 1 do
            -- LuaFormatter off
            local pos_rb = {x = pos.x + x    , y = pos.y + y    }
            local pos_rt = {x = pos.x + x    , y = pos.y - y - 1}
            local pos_lb = {x = pos.x - x - 1, y = pos.y + y    }
            local pos_lt = {x = pos.x - x - 1, y = pos.y - y - 1}
            -- LuaFormatter on
            local r = (math_sqrt(x ^ 2 + y ^ 2) - 5) / (ssa)
            local noise = 0.0
            noise = math_abs(Noises.silo_safe_area(pos_rb, seed))
            if noise > r then
                table_insert(tiles, {name = get_replacement_tile_name(surface, seed, pos_rb), position = pos_rb})
                table_insert(tiles, {name = 'stone-path', position = pos_rb})
                TerrainDebug.tile_spawn_silo(surface, pos_rb)
            end
            noise = math_abs(Noises.silo_safe_area(pos_rt, seed))
            if noise > r then
                table_insert(tiles, {name = get_replacement_tile_name(surface, seed, pos_rt), position = pos_rt})
                table_insert(tiles, {name = 'stone-path', position = pos_rt})
                TerrainDebug.tile_spawn_silo(surface, pos_rt)
            end
            noise = math_abs(Noises.silo_safe_area(pos_lb, seed))
            if noise > r then
                table_insert(tiles, {name = get_replacement_tile_name(surface, seed, pos_lb), position = pos_lb})
                table_insert(tiles, {name = 'stone-path', position = pos_lb})
                TerrainDebug.tile_spawn_silo(surface, pos_lb)
            end
            noise = math_abs(Noises.silo_safe_area(pos_lt, seed))
            if noise > r then

                table_insert(tiles, {name = get_replacement_tile_name(surface, seed, pos_lt), position = pos_lt})
                table_insert(tiles, {name = 'stone-path', position = pos_lt})
                TerrainDebug.tile_spawn_silo(surface, pos_lt)
            end
        end
    end
    surface.set_tiles(tiles)
    -- LuaFormatter off
    pos = {
        x = pos.x + dv.x*0.5,
        y = pos.y + dv.y*0.5,
    }
    -- LuaFormatter on
    -- clear entities on silo place
    for _, entity in pairs(surface.find_entities_filtered {
        area = {{pos.x - 5.4, pos.y - 5.4}, {pos.x + 5.6, pos.y + 5.6}}, type = {'simple-entity', 'tree', 'resource'},
    }) do entity.destroy() end

    -- create silo
    -- LuaFormatter off
    local silo = surface.create_entity({
        name = 'rocket-silo', force = force,
        position = pos })
    -- LuaFormatter on
    silo.minable = false
    global.rocket_silo[silo.force.name] = silo
    Functions.add_target_entity(global.rocket_silo[silo.force.name])

    -- LuaFormatter off
    pos = {
        x = pos.x + dv.x * 5.5,
        y = pos.y + dv.y * 5.5,
    }
    -- LuaFormatter on
    -- create turrets
    -- LuaFormatter off
    local turret = surface.create_entity({
        name = 'gun-turret', force = force,
        position = {
            x = pos.x + dv.y*2,
            y = pos.y - dv.x*2,
    }})
    turret.insert({name = 'firearm-magazine', count = 10})
    turret = surface.create_entity({
        name = 'gun-turret', force = force,
        position = {
            x = pos.x - dv.y*2,
            y = pos.y + dv.x*2,
    }})
    turret.insert({name = 'firearm-magazine', count = 10})
    -- LuaFormatter on
end


return generate_silo
