local TerrainParams = require 'terrain.params'
local Noises = require 'utils.noises'
local TerrainDebug = require 'terrain.debug'
local DirectionVectors = require 'utils.direction_vectors'
local Functions = require 'maps.biter_battles_v2.functions'
local get_replacement_tile = require'terrain.utils'.get_replacement_tile_name
local is_spawn_circle = require'terrain.spawn_circle'.contains
local is_river = require'terrain.river'.contains

local table_insert = table.insert
local math_floor = math.floor
local math_abs = math.abs
local math_sqrt = math.sqrt

local function is_horizontal_border_river(surface, seed, pos)
    if is_spawn_circle(surface, seed, pos) then return true end
    for _, direction in pairs(TerrainParams.river.directions) do
        if is_river(surface, seed, direction, pos) then return true end
    end
end


local function generate_starting_area(pos, distance_to_center, surface, seed, direction, force, entities)
    -- assert(distance_to_center >= spawn_circle_size) == true
    local random = game.create_random_generator(seed)
    local wall_radius = TerrainParams.walls.radius
    local wall_noise = TerrainParams.walls.noise

    if distance_to_center > wall_radius + 10 then return end

    wall_radius = wall_radius - math_abs(Noises.wall_distance(pos, seed)) * wall_noise

    if distance_to_center > wall_radius + 10 then return end

    local distance_from_spawn_wall = distance_to_center - wall_radius

    -- distance_from_spawn_wall is the difference between the distance_to_center (with added noise)
    -- and our spawn_wall radius (spawn_wall_radius=116), i.e. how far are we from the ring with radius spawn_wall_radius.
    -- The following shows what happens depending on distance_from_spawn_wall:
    --   	min     max
    --  	N/A     -10	    => replace water
    -- if noise_2 > -0.5:
    --      -1.75    0 	    => wall
    -- else:
    --   	-6      -3 	 	=> 1/16 chance of turret or turret-remnants
    --   	-1.95    0 	 	=> wall
    --    	 0       4.5    => chest-remnants with 1/3, chest with 1/(distance_from_spawn_wall+2)
    --
    -- => We never do anything for (distance_to_center + min_noise - spawn_wall_radius) > 4.5
    if is_horizontal_border_river(surface, seed, pos) then return end

    if distance_from_spawn_wall < 0 then
        if random(100) > 23 then
            for _, tree in pairs(surface.find_entities_filtered({
                type = 'tree', area = {{pos.x, pos.y}, {pos.x + 1, pos.y + 1}},
            })) do tree.destroy() end
        end
    end

    if distance_from_spawn_wall < -10 then
        local tile_name = surface.get_tile(pos).name
        if tile_name == 'water' or tile_name == 'deepwater' then
            surface.set_tiles({{name = get_replacement_tile(surface, seed, pos), position = pos}}, true)
        end
        return
    end

    if surface.can_place_entity({name = 'wooden-chest', position = pos})
      and surface.can_place_entity({name = 'coal', position = pos}) then
        local noise_2 = Noises.wall_entity(pos, seed)
        if noise_2 < 0.60 then
            if noise_2 > -0.40 then
                if distance_from_spawn_wall > -1.75 and distance_from_spawn_wall < 0 then
                    local e = surface.create_entity({name = 'stone-wall', position = pos, force = force})
                    table_insert(entities, e)
                    return;
                end
            else
                if distance_from_spawn_wall > -1.95 and distance_from_spawn_wall < 0 then
                    local e = surface.create_entity({name = 'stone-wall', position = pos, force = force})
                    table_insert(entities, e)
                    return
                elseif distance_from_spawn_wall > 0 and distance_from_spawn_wall < 4.5 then
                    local r_max = distance_from_spawn_wall + 2
                    local e = surface.create_entity {name = 'wooden-chest', position = pos, force = force}
                    table_insert(entities, e)
                    return
                elseif distance_from_spawn_wall > -6 and distance_from_spawn_wall < -3 then
                    if surface.can_place_entity({name = 'gun-turret', position = pos}) then
                        local e = surface.create_entity({name = 'gun-turret', position = pos, force = force})
                        e.insert({name = 'firearm-magazine', count = random(2, 16)})
                        Functions.add_target_entity(e)
                        table_insert(entities, e)
                        return
                    end
                end
            end
        end
    end
end


local function draw_spawn_area(surface, seed, direction, force)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed
    direction = direction or defines.direction.south
    force = force or game.forces.player

    local silo_distance = TerrainParams.silo_distance
    local wall_distance = TerrainParams.walls.radius + 10

    local random = game.create_random_generator(seed)
    local origin_offset = random(-0.75, 0.75) * silo_distance
    local dv = DirectionVectors[direction]

    -- LuaFormatter off
    local silo_pos = {
        x = math_floor (dv.x * silo_distance + dv.y * origin_offset + 0.5),
        y = math_floor (dv.y * silo_distance - dv.x * origin_offset + 0.5),
    }
    -- LuaFormatter on
    surface.request_to_generate_chunks(silo_pos, (16 + wall_distance) / 32 + 1)
    surface.force_generate_chunk_requests()

    local entities = {}

    for y = 0, wall_distance, 1 do
        for x = 0, wall_distance, 1 do
            -- LuaFormatter off
            local pos_rb = {
                x = silo_pos.x + x + 0.5,
                y = silo_pos.y + y + 0.5,
            }
            local pos_rt = {
                x = silo_pos.x + x + 0.5,
                y = silo_pos.y - y - 0.5,
            }
            local pos_lb = {
                x = silo_pos.x - x - 0.5,
                y = silo_pos.y + y + 0.5,
            }
            local pos_lt = {
                x = silo_pos.x - x - 0.5,
                y = silo_pos.y - y - 0.5,
            }
            -- LuaFormatter on
            local r = math_sqrt(x ^ 2 + y ^ 2)
            generate_starting_area(pos_rb, r, surface, seed, direction, force, entities)
            generate_starting_area(pos_rt, r, surface, seed, direction, force, entities)
            generate_starting_area(pos_lb, r, surface, seed, direction, force, entities)
            generate_starting_area(pos_lt, r, surface, seed, direction, force, entities)
        end
    end

    for _, e in pairs(entities) do if random(1, 100) < 70 then e.damage(random(0, 600), 'enemy') end end

    surface.destroy_decoratives({})
    surface.regenerate_decorative()
end


return draw_spawn_area
