local Public = {}
local LootRaffle = require 'functions.loot_raffle'
local BiterRaffle = require 'maps.biter_battles_v2.biter_raffle'
local bb_config = require 'maps.biter_battles_v2.config'
local Functions = require 'maps.biter_battles_v2.functions'
local tables = require 'maps.biter_battles_v2.tables'

local TerrainNg = require 'terrain.main'


local spawn_ore = tables.spawn_ore
local table_insert = table.insert
local math_floor = math.floor
local math_random = math.random
local math_abs = math.abs
local math_sqrt = math.sqrt

local Noises = require 'utils.noises'
local mixed_ore = require 'terrain.mixed_ore'
local TerrainDebug = require 'terrain.debug'

local simplex_noise = require 'utils.simplex_noise'
local spawn_circle_radius = 39

local rocks = {'rock-huge', 'rock-big', 'rock-big', 'rock-big', 'sand-rock-big'}

local chunk_tile_vectors = {}
for x = 0, 31, 1 do for y = 0, 31, 1 do chunk_tile_vectors[#chunk_tile_vectors + 1] = {x, y} end end
local size_of_chunk_tile_vectors = #chunk_tile_vectors

local loading_chunk_vectors = {}
for _, v in pairs(chunk_tile_vectors) do
    if v[1] == 0 or v[1] == 31 or v[2] == 0 or v[2] == 31 then table_insert(loading_chunk_vectors, v) end
end

local wrecks = {
    'crash-site-spaceship-wreck-big-1', 'crash-site-spaceship-wreck-big-2', 'crash-site-spaceship-wreck-medium-1',
    'crash-site-spaceship-wreck-medium-2', 'crash-site-spaceship-wreck-medium-3',
}
local size_of_wrecks = #wrecks
local valid_wrecks = {}
for _, wreck in pairs(wrecks) do valid_wrecks[wreck] = true end
local loot_blacklist = {
    ['automation-science-pack'] = true, ['logistic-science-pack'] = true, ['military-science-pack'] = true,
    ['chemical-science-pack'] = true, ['production-science-pack'] = true, ['utility-science-pack'] = true,
    ['space-science-pack'] = true, ['loader'] = true, ['fast-loader'] = true, ['express-loader'] = true,
}

local function shuffle(tbl)
    local size = #tbl
    for i = size, 1, -1 do
        local rand = math_random(size)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
end


local function create_mirrored_tile_chain(surface, tile, count, straightness)
    if not surface then return end
    if not tile then return end
    if not count then return end

    local position = {x = tile.position.x, y = tile.position.y}

    local modifiers = {
        {x = 0, y = -1}, {x = -1, y = 0}, {x = 1, y = 0}, {x = 0, y = 1}, {x = -1, y = 1}, {x = 1, y = -1},
        {x = 1, y = 1}, {x = -1, y = -1},
    }
    modifiers = shuffle(modifiers)

    for _ = 1, count, 1 do
        local tile_placed = false

        if math_random(0, 100) > straightness then modifiers = shuffle(modifiers) end
        for b = 1, 4, 1 do
            local pos = {x = position.x + modifiers[b].x, y = position.y + modifiers[b].y}
            if surface.get_tile(pos).name ~= tile.name then
                surface.set_tiles({{name = 'landfill', position = pos}}, true)
                surface.set_tiles({{name = tile.name, position = pos}}, true)
                -- surface.set_tiles({{name = "landfill", position = {pos.x * -1, (pos.y * -1) - 1}}}, true)
                -- surface.set_tiles({{name = tile.name, position = {pos.x * -1, (pos.y * -1) - 1}}}, true)
                position = {x = pos.x, y = pos.y}
                tile_placed = true
                break
            end
        end

        if not tile_placed then position = {x = position.x + modifiers[1].x, y = position.y + modifiers[1].y} end
    end
end


local function get_replacement_tile(surface, position)
    for i = 1, 128, 1 do
        local vectors = {{0, i}, {0, i * -1}, {i, 0}, {i * -1, 0}}
        table.shuffle_table(vectors)
        for _, v in pairs(vectors) do
            local tile = surface.get_tile(position.x + v[1], position.y + v[2])
            if not tile.collides_with('resource-layer') then
                if tile.name ~= 'stone-path' then return tile.name end
            end
        end
    end
    return 'grass-1'
end


local river_y_1 = bb_config.border_river_width * -1.5
local river_y_2 = bb_config.border_river_width * 1.5
local river_width_half = math_floor(bb_config.border_river_width * -0.5)
local function is_horizontal_border_river(pos)
    local seed = game.surfaces[global.bb_surface_name].map_gen_settings.seed
    if pos.y < river_y_1 then return false end
    if pos.y > river_y_2 then return false end
    if pos.y >= river_width_half - (math_abs(Noises.river(pos, seed)) * 4) then return true end
    return false
end


local function generate_starting_area(pos, distance_to_center, surface)
    -- assert(distance_to_center >= spawn_circle_size) == true
    local spawn_wall_radius = 116
    local noise_multiplier = 15
    local min_noise = -noise_multiplier * 1.25

    -- Avoid calculating noise, see comment below
    if (distance_to_center + min_noise - spawn_wall_radius) > 4.5 then return end

    local seed = game.surfaces[global.bb_surface_name].map_gen_settings.seed
    local noise = Noises.wall_distance(pos, seed) * 1.2 * noise_multiplier
    local distance_from_spawn_wall = distance_to_center + noise - spawn_wall_radius
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

    if distance_from_spawn_wall < 0 then
        if math_random(1, 100) > 23 then
            for _, tree in pairs(surface.find_entities_filtered({
                type = 'tree', area = {{pos.x, pos.y}, {pos.x + 1, pos.y + 1}},
            })) do tree.destroy() end
        end
    end

    if distance_from_spawn_wall < -10 and not is_horizontal_border_river(pos) then
        local tile_name = surface.get_tile(pos).name
        if tile_name == 'water' or tile_name == 'deepwater' then
            surface.set_tiles({{name = get_replacement_tile(surface, pos), position = pos}}, true)
        end
        return
    end

    if surface.can_place_entity({name = 'wooden-chest', position = pos})
      and surface.can_place_entity({name = 'coal', position = pos}) then
        local noise_2 = Noises.wall_entity(pos, seed) * 1.35
        if noise_2 < 0.40 then
            if noise_2 > -0.40 then
                if distance_from_spawn_wall > -1.75 and distance_from_spawn_wall < 0 then
                    local e = surface.create_entity({name = 'stone-wall', position = pos, force = 'north'})
                end
            else
                if distance_from_spawn_wall > -1.95 and distance_from_spawn_wall < 0 then
                    local e = surface.create_entity({name = 'stone-wall', position = pos, force = 'north'})

                elseif distance_from_spawn_wall > 0 and distance_from_spawn_wall < 4.5 then
                    local name = 'wooden-chest'
                    local r_max = math_floor(math.abs(distance_from_spawn_wall)) + 2
                    if math_random(1, 3) == 1 and not is_horizontal_border_river(pos) then
                        name = name .. '-remnants'
                    end
                    if math_random(1, r_max) == 1 then
                        local e = surface.create_entity({name = name, position = pos, force = 'north'})
                    end

                elseif distance_from_spawn_wall > -6 and distance_from_spawn_wall < -3 then
                    if math_random(1, 16) == 1 then
                        if surface.can_place_entity({name = 'gun-turret', position = pos}) then
                            local e = surface.create_entity({name = 'gun-turret', position = pos, force = 'north'})
                            e.insert({name = 'firearm-magazine', count = math_random(2, 16)})
                            Functions.add_target_entity(e)
                        end
                    else
                        if math_random(1, 24) == 1 and not is_horizontal_border_river(pos) then
                            if surface.can_place_entity({name = 'gun-turret', position = pos}) then
                                surface.create_entity({name = 'gun-turret-remnants', position = pos, force = 'neutral'})
                            end
                        end
                    end
                end
            end
        end
    end
end


local generate_river = require'terrain.river'.generate

local scrap_vectors = {}
for x = -8, 8, 1 do
    for y = -8, 8, 1 do if math_sqrt(x ^ 2 + y ^ 2) <= 8 then scrap_vectors[#scrap_vectors + 1] = {x, y} end end
end
local size_of_scrap_vectors = #scrap_vectors

local function generate_extra_worm_turrets(surface, left_top)
    local chunk_distance_to_center = math_sqrt(left_top.x ^ 2 + left_top.y ^ 2)
    if bb_config.bitera_area_distance > chunk_distance_to_center then return end

    local amount = (chunk_distance_to_center - bb_config.bitera_area_distance) * 0.0005
    if amount < 0 then return end
    local floor_amount = math_floor(amount)
    local r = math.round(amount - floor_amount, 3) * 1000
    if math_random(0, 999) <= r then floor_amount = floor_amount + 1 end

    if floor_amount > 64 then floor_amount = 64 end

    for _ = 1, floor_amount, 1 do
        local worm_turret_name = BiterRaffle.roll('worm', chunk_distance_to_center * 0.00015)
        local v = chunk_tile_vectors[math_random(1, size_of_chunk_tile_vectors)]
        local position = surface.find_non_colliding_position(worm_turret_name, {left_top.x + v[1], left_top.y + v[2]},
          8, 1)
        if position then
            local worm = surface.create_entity({name = worm_turret_name, position = position, force = 'north_biters'})

            -- add some scrap
            for _ = 1, math_random(0, 4), 1 do
                local vector = scrap_vectors[math_random(1, size_of_scrap_vectors)]
                local position = {worm.position.x + vector[1], worm.position.y + vector[2]}
                local name = wrecks[math_random(1, size_of_wrecks)]
                position = surface.find_non_colliding_position(name, position, 16, 1)
                if position then
                    local e = surface.create_entity({name = name, position = position, force = 'neutral'})
                end
            end
        end
    end
end


local bitera_area_distance = bb_config.bitera_area_distance * -1
local biter_area_angle = 0.45

local function is_biter_area(position)
    local seed = game.surfaces[global.bb_surface_name].map_gen_settings.seed
    local a = bitera_area_distance - (math_abs(position.x) * biter_area_angle)
    if position.y - 70 > a then return false end
    if position.y + 70 < a then return true end
    if position.y + (Noises.biter_distance(position, seed) * 64) > a then return false end
    return true
end


local function draw_biter_area(surface, left_top_x, left_top_y)
    if not is_biter_area({x = left_top_x, y = left_top_y - 96}) then return end

    local seed = game.surfaces[global.bb_surface_name].map_gen_settings.seed

    local out_of_map = {}
    local tiles = {}
    local i = 1

    for x = 0, 31, 1 do
        for y = 0, 31, 1 do
            local position = {x = left_top_x + x, y = left_top_y + y}
            if is_biter_area(position) then
                local index = math_floor(Noises.biterland(position, seed) * 48) % 7 + 1
                out_of_map[i] = {name = 'out-of-map', position = position}
                tiles[i] = {name = 'dirt-' .. index, position = position}
                i = i + 1
            end
        end
    end

    surface.set_tiles(out_of_map, false)
    surface.set_tiles(tiles, true)

    for _ = 1, 4, 1 do
        local v = chunk_tile_vectors[math_random(1, size_of_chunk_tile_vectors)]
        local position = {x = left_top_x + v[1], y = left_top_y + v[2]}
        if is_biter_area(position) and surface.can_place_entity({name = 'spitter-spawner', position = position}) then
            local e
            if math_random(1, 4) == 1 then
                e = surface.create_entity({name = 'spitter-spawner', position = position, force = 'north_biters'})
            else
                e = surface.create_entity({name = 'biter-spawner', position = position, force = 'north_biters'})
            end
            table.insert(global.unit_spawners[e.force.name], e)
        end
    end

    local e = (math_abs(left_top_y) - bb_config.bitera_area_distance) * 0.0015
    for _ = 1, math_random(5, 10), 1 do
        local v = chunk_tile_vectors[math_random(1, size_of_chunk_tile_vectors)]
        local position = {x = left_top_x + v[1], y = left_top_y + v[2]}
        local worm_turret_name = BiterRaffle.roll('worm', e)
        if is_biter_area(position) and surface.can_place_entity({name = worm_turret_name, position = position}) then
            surface.create_entity({name = worm_turret_name, position = position, force = 'north_biters'})
        end
    end
end


function Public.generate(event)
    TerrainNg.generate(event)
    local surface = event.surface
    local left_top = event.area.left_top
    local left_top_x = left_top.x
    local left_top_y = left_top.y
    -- generate_river(surface, nil, defines.direction.northeast, left_top)
    draw_biter_area(surface, left_top_x, left_top_y)
    generate_extra_worm_turrets(surface, left_top)
end


function Public.draw_spawn_area(surface)
    local chunk_r = 4
    local r = chunk_r * 32

    for x = r * -1, r, 1 do
        for y = r * -1, -4, 1 do
            local pos = {x = x, y = y}
            local distance_to_center = math_sqrt(pos.x ^ 2 + pos.y ^ 2)
            generate_starting_area(pos, distance_to_center, surface)
        end
    end

    surface.destroy_decoratives({})
    surface.regenerate_decorative()
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


function Public.clear_ore_in_main(surface)
    local area = {left_top = {-150, -150}, right_bottom = {150, 0}}
    local limit = 20
    local cnt = 0
    repeat
        -- Keep clearing resources until there is none.
        -- Each cycle increases search area.
        cnt = _clear_resources(surface, area)
        limit = limit - 1
        area.left_top[1] = area.left_top[1] - 5
        area.left_top[2] = area.left_top[2] - 5
        area.right_bottom[1] = area.right_bottom[1] + 5
    until cnt == 0 or limit == 0

    if limit == 0 then
        log('Limit reached, some ores might be truncated in spawn area')
        log('If this is a custom build, remove a call to clear_ore_in_main')
        log('If this in a standard value, limit could be tweaked')
    end
end


function Public.generate_additional_rocks(surface)
    local r = 130
    if surface.count_entities_filtered({type = 'simple-entity', area = {{r * -1, r * -1}, {r, 0}}}) >= 12 then return end
    local position = {x = -96 + math_random(0, 192), y = -40 - math_random(0, 96)}
    for _ = 1, math_random(6, 10) do
        local name = rocks[math_random(1, 5)]
        local p = surface.find_non_colliding_position(name, {
            position.x + (-10 + math_random(0, 20)), position.y + (-10 + math_random(0, 20)),
        }, 16, 1)
        if p and p.y < -16 then
            TerrainDebug.tile_debug_render(surface, p, 0.8)
            surface.create_entity({name = name, position = p})
        end
    end
end


--[[
function Public.generate_spawn_goodies(surface)
	local tiles = surface.find_tiles_filtered({name = "stone-path"})
	table.shuffle_table(tiles)
	local budget = 1500
	local min_roll = 30
	local max_roll = 600
	local blacklist = {
		["automation-science-pack"] = true,
		["logistic-science-pack"] = true,
		["military-science-pack"] = true,
		["chemical-science-pack"] = true,
		["production-science-pack"] = true,
		["utility-science-pack"] = true,
		["space-science-pack"] = true,
		["loader"] = true,
		["fast-loader"] = true,
		["express-loader"] = true,
	}
	local container_names = {"wooden-chest", "wooden-chest", "iron-chest"}
	for k, tile in pairs(tiles) do
		if budget <= 0 then return end
		if surface.can_place_entity({name = "wooden-chest", position = tile.position, force = "neutral"}) then
			local v = math_random(min_roll, max_roll)
			local item_stacks = LootRaffle.roll(v, 4, blacklist)
			local container = surface.create_entity({name = container_names[math_random(1, 3)], position = tile.position, force = "neutral"})
			for _, item_stack in pairs(item_stacks) do container.insert(item_stack)	end
			budget = budget - v
		end
	end
end
]]

function Public.minable_wrecks(event)
    local entity = event.entity
    if not entity then return end
    if not entity.valid then return end
    if not valid_wrecks[entity.name] then return end

    local surface = entity.surface
    local player = game.players[event.player_index]

    local loot_worth = math_floor(math_abs(entity.position.x * 0.02)) + math_random(16, 32)
    local blacklist = LootRaffle.get_tech_blacklist(math_abs(entity.position.x * 0.0001) + 0.10)
    for k, _ in pairs(loot_blacklist) do blacklist[k] = true end
    local item_stacks = LootRaffle.roll(loot_worth, math_random(1, 3), blacklist)

    for k, stack in pairs(item_stacks) do
        local amount = stack.count
        local name = stack.name

        local inserted_count = player.insert({name = name, count = amount})
        if inserted_count ~= amount then
            local amount_to_spill = amount - inserted_count
            surface.spill_item_stack(entity.position, {name = name, count = amount_to_spill}, true)
        end

        surface.create_entity({
            name = 'flying-text', position = {entity.position.x, entity.position.y - 0.5 * k},
            text = '+' .. amount .. ' [img=item/' .. name .. ']', color = {r = 0.98, g = 0.66, b = 0.22},
        })
    end
end


-- Landfill Restriction
function Public.restrict_landfill(surface, inventory, tiles)
    for _, t in pairs(tiles) do
        local distance_to_center = math_sqrt(t.position.x ^ 2 + t.position.y ^ 2)
        local check_position = t.position
        if check_position.y > 0 then
            check_position = {x = check_position.x * -1, y = (check_position.y * -1) - 1}
        end
        if is_horizontal_border_river(check_position) or distance_to_center < spawn_circle_radius then
            surface.set_tiles({{name = t.old_tile.name, position = t.position}}, true)
        end
    end
end


function Public.deny_bot_landfill(event)
    Public.restrict_landfill(event.robot.surface, event.robot.get_inventory(defines.inventory.robot_cargo), event.tiles)
end


-- Construction Robot Restriction
local robot_build_restriction = {
    ['north'] = function(y) if y >= -10 then return true end end
, ['south'] = function(y) if y <= 10 then return true end end
,
}

function Public.deny_construction_bots(event)
    if not robot_build_restriction[event.robot.force.name] then return end
    if not robot_build_restriction[event.robot.force.name](event.created_entity.position.y) then return end
    local inventory = event.robot.get_inventory(defines.inventory.robot_cargo)
    inventory.insert({name = event.created_entity.name, count = 1})
    event.robot.surface.create_entity({name = 'explosion', position = event.created_entity.position})
    game.print('Team ' .. event.robot.force.name .. '\'s construction drone had an accident.',
      {r = 200, g = 50, b = 100})
    event.created_entity.destroy()
end


function Public.draw_structures()

    local surface = game.surfaces[global.bb_surface_name]
    Public.draw_spawn_area(surface)
    Public.clear_ore_in_main(surface)
    Public.generate_additional_rocks(surface)
    TerrainNg.draw_structures()
    -- Public.generate_spawn_goodies(surface)
end


return Public
