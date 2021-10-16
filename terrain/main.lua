local draw_spawn_circle = require'terrain.spawn_circle'.draw
local generate_silo = require 'terrain.silo'

local Terrain = {}

Terrain.is_spawn_circle = require'terrain.spawn_circle'.contains

function Terrain.draw_structures()
    local surface = game.surfaces[global.bb_surface_name]
    -- Public.draw_spawn_area(surface)
    -- Public.clear_ore_in_main(surface)
    -- Public.generate_spawn_ore(surface)
    -- Public.generate_additional_rocks(surface)
    generate_silo(surface, nil, defines.direction.south)
    generate_silo(surface, nil, defines.direction.southwest)
    generate_silo(surface, nil, defines.direction.west)
    generate_silo(surface, nil, defines.direction.northwest)
    generate_silo(surface, nil, defines.direction.north)
    generate_silo(surface, nil, defines.direction.northeast)
    generate_silo(surface, nil, defines.direction.east)
    generate_silo(surface, nil, defines.direction.southeast)
    draw_spawn_circle(surface)
    -- Public.generate_spawn_goodies(surface)
end


return Terrain
