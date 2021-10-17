local TerrainDebug = require 'terrain.debug'
local draw_spawn_circle = require'terrain.spawn_circle'.draw
local generate_silo = require 'terrain.silo'
local generate_spawn_ore = require'terrain.spawn_ores'.generate_spawn_ore
local clear_ore_in_main = require'terrain.spawn_ores'.clear_ore_in_main
local generate_additional_rocks = require 'terrain.rocks'
local mixed_ore = require 'terrain.mixed_ore'
local generate_river = require'terrain.river'.generate

local Terrain = {}

Terrain.is_spawn_circle = require'terrain.spawn_circle'.contains
Terrain.is_river = require'terrain.river'.contains

function Terrain.draw_structures()
    local surface = game.surfaces[global.bb_surface_name]

    -- Public.draw_spawn_area(surface)

    clear_ore_in_main(surface, defines.direction.south)
    clear_ore_in_main(surface, defines.direction.north)
    -- clear_ore_in_main(surface, defines.direction.east)
    -- clear_ore_in_main(surface, defines.direction.west)

    generate_additional_rocks(surface, nil, defines.direction.south)
    generate_additional_rocks(surface, nil, defines.direction.north)

    generate_spawn_ore(surface, nil, defines.direction.south)
    generate_spawn_ore(surface, nil, defines.direction.north)
    -- generate_spawn_ore(surface, nil, defines.direction.east)
    -- generate_spawn_ore(surface, nil, defines.direction.west)
    -- generate_spawn_ore(surface, nil, defines.direction.north)

    generate_silo(surface, nil, defines.direction.south)
    generate_silo(surface, nil, defines.direction.north)
    -- generate_silo(surface, nil, defines.direction.east)
    -- generate_silo(surface, nil, defines.direction.west)
    -- generate_silo(surface, nil, defines.direction.southwest)
    -- generate_silo(surface, nil, defines.direction.west)
    -- generate_silo(surface, nil, defines.direction.northwest)
    -- generate_silo(surface, nil, defines.direction.north)
    -- generate_silo(surface, nil, defines.direction.northeast)
    -- generate_silo(surface, nil, defines.direction.east)
    -- generate_silo(surface, nil, defines.direction.southeast)

    draw_spawn_circle(surface)
    -- Public.generate_spawn_goodies(surface)
end


function Terrain.generate(event)

    local surface = event.surface
    local left_top = event.area.left_top
    local left_top_x = left_top.x
    local left_top_y = left_top.y

    for y = 0, 31, 1 do
        for x = 0, 31, 1 do
            local pos = {x = left_top_x + x, y = left_top_y + y}
            if Terrain.is_spawn_circle(surface, nil, pos) then TerrainDebug.tile_spawner(surface, pos) end
            if Terrain.is_river(surface, nil, defines.direction.east, pos) then
                TerrainDebug.tile_river(surface, pos)
            end
            if Terrain.is_river(surface, nil, defines.direction.west, pos) then
                TerrainDebug.tile_river(surface, pos)
            end
        end
    end

    mixed_ore(surface, nil, left_top_x, left_top_y)
    generate_river(surface, nil, defines.direction.east, left_top)
    generate_river(surface, nil, defines.direction.west, left_top)
    -- generate_river(surface, nil, defines.direction.southwest, left_top)
    -- generate_river(surface, nil, defines.direction.northwest, left_top)
    -- generate_river(surface, nil, defines.direction.northeast, left_top)
    -- generate_river(surface, nil, defines.direction.southeast, left_top)
end


return Terrain
