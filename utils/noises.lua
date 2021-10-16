local simplex_noise = require 'utils.simplex_noise'

local Noises = {}

-- LuaFormatter off
local noise_params = {
    biterland = {
        {seed =     0, size = 0.0010, weight = 1.000, },
        {seed = 10000, size = 0.0100, weight = 0.350, },
        {seed = 10000, size = 0.1000, weight = 0.015, },
    },
    biter_distance = {
        {seed =     0, size = 0.0050, weight = 1.000, },
        {seed =     0, size = 0.0200, weight = 0.300, },
        {seed =     0, size = 0.1500, weight = 0.025, },
    },
    ore = {
        {seed =     0, size = 0.0042, weight = 1.000, },
        {seed = 10000, size = 0.0310, weight = 0.080, },
        {seed = 10000, size = 0.1000, weight = 0.025, },
    },
    river = {
        {seed =     0, size = 0.0042, weight = 1.000, },
        {seed = 25000, size = 0.0310, weight = 0.080, },
        {seed = 25000, size = 0.1000, weight = 0.025, },
    },
    wall_distance = {
        {seed =     0, size = 0.0110, weight = 1.000, },
        {seed = 25000, size = 0.0080, weight = 0.200, },
    },
    wall_entity = {
        {seed =     0, size = 0.0050, weight = 1.000, },
        {seed =     0, size = 0.0200, weight = 0.300, },
        {seed =     0, size = 0.1500, weight = 0.025, },
    },
}
-- LuaFormatter on

local function get_noise(noise_param, pos, seed)
    local noise = 0
    local d = 0
    for i = 1, #noise_param do
        seed = seed + noise_param[i].seed
        noise = noise + simplex_noise(pos.x * noise_param[i].size, pos.y * noise_param[i].size, seed)
                  * noise_param[i].weight
        d = d + noise_param[i].weight
    end
    return noise / d
end


function Noises.biterland(pos, seed) return get_noise(noise_params.biterland, pos, seed) end


function Noises.biter_distance(pos, seed) return get_noise(noise_params.biter_distance, pos, seed) end


function Noises.ore(pos, seed) return get_noise(noise_params.ore, pos, seed) end


function Noises.river(pos, seed) return get_noise(noise_params.river, pos, seed) end


function Noises.wall_distance(pos, seed) return get_noise(noise_params.wall_distance, pos, seed) end


function Noises.wall_entity(pos, seed) return get_noise(noise_params.wall_entity, pos, seed) end


return Noises
