local simplex_noise = require 'utils.simplex_noise'.d2

local Public = {}

function Public.biterland(pos)
    local seed =  game.surfaces[global.bb_surface_name].map_gen_settings.seed
    local noise = 0
    local d = 0
    local modifier
    local weight
    local seed_step = 10000

    modifier = 0.0010
    weight = 1.000
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.0100
    weight   = 0.350
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.1000
    weight = 0.015
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    noise = noise / d
    return noise
end

function Public.ore(pos)
    local seed =  game.surfaces[global.bb_surface_name].map_gen_settings.seed
    local noise = 0
    local d = 0
    local modifier
    local weight
    local seed_step = 10000

    modifier = 0.0042
    weight = 1.000
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.0310
    weight   = 0.080
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.1000
    weight = 0.025
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    return noise / d
end


function Public.river(pos)
    local seed =  game.surfaces[global.bb_surface_name].map_gen_settings.seed
    local noise = 0.0
    local d = 0.0
    local modifier
    local weight
    local seed_step = 25000

    modifier = 0.0042
    weight = 1.000
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.0310
    weight   = 0.080
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.1000
    weight = 0.025
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    return noise / d
end


function Public.u2(pos)
    local seed =  game.surfaces[global.bb_surface_name].map_gen_settings.seed
    local noise = 0.0
    local d = 0.0
    local modifier
    local weight
    local seed_step = 25000

    modifier = 0.0110
    weight = 1.000
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.0800
    weight   = 0.200
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    return noise / d
end


function Public.u3(pos)
    local seed =  game.surfaces[global.bb_surface_name].map_gen_settings.seed
    local noise = 0.0
    local d = 0.0
    local modifier
    local weight
    local seed_step = 25000

    modifier = 0.0050
    weight = 1.000
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.0200
    weight   = 0.300
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    modifier = 0.1500
    weight   = 0.0025
    noise = noise + simplex_noise(pos.x * modifier, pos.y * modifier, seed) * weight
    d = d + weight
    seed = seed + seed_step

    return noise / d
end

return Public
