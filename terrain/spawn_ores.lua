local Noises = require 'utils.noises'
local TerrainDebug = require 'terrain.debug'
local DirectionVectors = require 'utils.direction_vectors'

local TerrainParams = require 'terrain.table'
local table_insert = table.insert
local table_remove = table.remove
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_abs = math.abs
local math_sqrt = math.sqrt

local Public = {}

local function draw_noise_ore_patch(surface, seed, name, position, radius, richness)

    surface.request_to_generate_chunks(position, (radius * 3) / 32 + 1)
    surface.force_generate_chunk_requests()

    local richness_part = richness / radius
    for y = radius * -3, radius * 3, 1 do
        for x = radius * -3, radius * 3, 1 do
            local pos = {x = x + position.x + 0.5, y = y + position.y + 0.5}
            local noise = Noises.spawn_ore(pos, seed) * 1.12
            local distance_to_center = math_sqrt(x ^ 2 + y ^ 2)
            local a = richness - richness_part * distance_to_center
            if distance_to_center < radius - math_abs(noise * radius * 0.85) and a > 1 then
                if surface.can_place_entity({name = name, position = pos, amount = a}) then
                    TerrainDebug.tile_debug_render(surface, pos, (noise + 1.15) / 2.3)
                    surface.create_entity {name = name, position = pos, amount = a}
                    for _, e in pairs(surface.find_entities_filtered({
                        position = pos, name = {'wooden-chest', 'stone-wall', 'gun-turret'},
                    })) do e.destroy() end
                end
            end
        end
    end
end


local function draw_grid_ore_patch(surface, seed, random, count, grid, name, radius, richness)
    if not name then return end
    if not radius then return end
    if not richness then return end

    -- Takes a random left_top coordinate from grid, removes it and draws
    -- ore patch on top of it. Grid is held by reference, so this function
    -- is reentrant.
    for i = 1, count, 1 do
        local idx = math_floor(random(1.1, #grid + 0.9))
        local pos = grid[idx]
        table_remove(grid, idx)
        draw_noise_ore_patch(surface, seed, name, pos, radius, richness)
    end
end


function Public.generate_spawn_ore(surface, seed, direction)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south

    local silo_distance = TerrainParams.silo_distance
    local dv = DirectionVectors[direction]
    local spawn_ore = TerrainParams.spawn_ore

    -- This array holds indicies of chunks onto which we desire to
    -- generate ore patches. It is visually representing north spawn
    -- area. One element was removed on purpose - we don't want to
    -- draw ore in the lake which overlaps with chunk [0,-1]. All ores
    -- will be mirrored to south.
    -- local grid = {
    --     {-2, -3}, {-1, -3}, {0, -3}, {1, -3}, {2, -3}, {-2, -2}, {-1, -2}, {0, -2}, {1, -2}, {2, -2}, {-2, -1},
    --     {-1, -1}, {1, -1}, {2, -1},
    -- }
    local grid = {}
    local random = game.create_random_generator(seed)

    -- Calculate left_top position of a chunk. It will be used as origin
    -- for ore drawing. Reassigns new coordinates to the grid.
    -- for i, _ in ipairs(grid) do
    --     grid[i][1] = grid[i][1] * 32 + math.random(-12, 12)
    --     grid[i][2] = grid[i][2] * 32 + math.random(-24, -1)
    -- end
    local offset = 0.0
    local od = silo_distance / 2
    for y = 1, 3, 1 do
        for x = 0, y, 1 do
            offset = random(-0.4, 0.4)
            -- LuaFormatter off
            table_insert(grid, {
                x = (dv.x * y - (x + offset) * dv.y) * od,
                y = (dv.y * y + (x + offset) * dv.x) * od,
            })
            offset = random(-0.4, 0.4)
            table_insert(grid, {
                x = (dv.x * y + (x + offset) * dv.y) * od,
                y = (dv.y * y - (x + offset) * dv.x) * od,
            })
            -- LuaFormatter on
        end
    end

    for name, props in pairs(spawn_ore) do
        draw_grid_ore_patch(surface, seed, random, props.big_patches, grid, name, props.size, props.density)
        draw_grid_ore_patch(surface, seed, random, props.small_patches, grid, name, props.size / 2, props.density)
    end
end


local function _clear_resources(surface, area)
    local resources = surface.find_entities_filtered {area = area, type = 'resource'}

    local i = 0
    for _, res in pairs(resources) do
        if not res.valid then goto clear_resources_cont end
        res.destroy()
        i = i + 1

        ::clear_resources_cont::
    end

    return i
end


function Public.clear_ore_in_main(surface, direction)
    direction = direction or defines.direction.south

    local sd = TerrainParams.silo_distance * 2
    local dv = DirectionVectors[direction]

    surface.request_to_generate_chunks({x = 0.0, y = 0.0}, sd / 32 + 1)
    surface.force_generate_chunk_requests()

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
    local limit = 20
    local cnt = 0
    repeat
        -- Keep clearing resources until there is none.
        -- Each cycle increases search area.
        cnt = _clear_resources(surface, {left_top = left_top, right_bottom = right_bottom})
        limit = limit - 1
        left_top.x = left_top.x - 5
        left_top.y = left_top.y - 5
        right_bottom.x = right_bottom.x + 5
        right_bottom.y = right_bottom.y + 5
    until cnt == 0 or limit == 0

    if limit == 0 then
        log('Limit reached, some ores might be truncated in spawn area')
        log('If this is a custom build, remove a call to clear_ore_in_main')
        log('If this in a standard value, limit could be tweaked')
    end
end


return Public
