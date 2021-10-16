local Noises = require 'utils.noises'
local TerrainDebug = require 'terrain.debug'
local DirectionVectors = require 'utils.direction_vectors'
local Functions = require 'maps.biter_battles_v2.functions'

local spawn_ore = require'maps.biter_battles_v2.tables'.spawn_ore
local table_insert = table.insert
local table_remove = table.remove
local math_floor = math.floor
local math_random = math.random
local math_abs = math.abs
local math_sqrt = math.sqrt

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


local function draw_grid_ore_patch(surface, seed, count, grid, name, radius, richness)
    if not name then return end
    if not radius then return end
    if not richness then return end

    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed

    -- Takes a random left_top coordinate from grid, removes it and draws
    -- ore patch on top of it. Grid is held by reference, so this function
    -- is reentrant.
    for i = 1, count, 1 do
        local idx = math_floor((math_abs(Noises.random({x = i, y = grid[1].y}, seed)) * (#grid - 0.02)) + 1.01)
        local pos = grid[idx]
        table_remove(grid, idx)
        draw_noise_ore_patch(surface, seed, name, pos, radius, richness)
    end
end


local function generate_spawn_ore(surface, seed, direction)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south

    local dv = DirectionVectors[direction]

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

    -- Calculate left_top position of a chunk. It will be used as origin
    -- for ore drawing. Reassigns new coordinates to the grid.
    -- for i, _ in ipairs(grid) do
    --     grid[i][1] = grid[i][1] * 32 + math.random(-12, 12)
    --     grid[i][2] = grid[i][2] * 32 + math.random(-24, -1)
    -- end
    for y = 2, 5, 1 do
        for x = 0, y, 1 do
            local noise = Noises.random({x = x, y = y}, seed)
            table_insert(grid, {x = (dv.x * x + noise * dv.y) * 32, y = (dv.y * y - noise * dv.x) * 32})
            table_insert(grid, {x = (dv.x * x + noise * dv.y) * 32, y = (dv.y * y - noise * dv.x) * 32})
        end
    end

    for name, props in pairs(spawn_ore) do
        draw_grid_ore_patch(surface, seed, props.big_patches, grid, name, props.size, props.density)
        draw_grid_ore_patch(surface, seed, props.small_patches, grid, name, props.size / 2, props.density)
    end
end


return generate_spawn_ore
