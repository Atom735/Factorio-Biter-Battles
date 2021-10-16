local Noises = require 'utils.noises'
local TerrainParams = require 'terrain.table'

local math_floor = math.floor
local math_abs = math.abs
local math_sqrt = math.sqrt

local function mixed_ore(surface, seed, left_top_x, left_top_y)
    surface = surface or game.surfaces[global.bb_surface_name]
    seed = seed or surface.map_gen_settings.seed

    local noise = Noises.ore({x = left_top_x + 16, y = left_top_y + 16}, seed)
    local random = game.create_random_generator(seed + math_abs(left_top_x + 113 + left_top_y * 7))

    -- Draw noise text values to determine which chunks are valid for mixed ore.
    -- rendering.draw_text{text = noise, surface = game.surfaces.biter_battles, target = {x = left_top_x + 16, y = left_top_y + 16}, color = {255, 255, 255}, scale = 2, font = "default-game"}

    -- Skip chunks that are too far off the ore noise value.
    if noise < 0.42 then return end

    local ores = TerrainParams.mixed_ores
    local mixed_ore_multiplier = TerrainParams.mixed_ore_multiplier

    -- Draw the mixed ore patches.
    for x = 0, 31, 1 do
        for y = 0, 31, 1 do
            local pos = {x = left_top_x + x, y = left_top_y + y}
            if surface.can_place_entity({name = 'iron-ore', position = pos}) then
                noise = Noises.ore(pos, seed)
                if noise > 0.72 then
                    local i = math_floor(noise * 25 + math_abs(pos.x) * 0.05) % 4 + 1
                    local amount = (random(800, 1000) + math_sqrt(pos.x ^ 2 + pos.y ^ 2) * 3) * mixed_ore_multiplier[i]
                    surface.create_entity({name = ores[i], position = pos, amount = amount})
                end
            end
        end
    end

    if left_top_y == -32 and math_abs(left_top_x) <= 32 then
        for _, e in pairs(surface.find_entities_filtered({
            name = 'character', invert = true, area = {{-12, -12}, {12, 12}},
        })) do e.destroy() end
    end
end


return mixed_ore
