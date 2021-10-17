local TerrainDebug = require 'terrain.debug'
local TerrainParams = require 'terrain.table'
local draw_spawn_circle = require'terrain.spawn_circle'.draw
local generate_silo = require 'terrain.silo'
local generate_spawn_ore = require'terrain.spawn_ores'.generate_spawn_ore
local clear_ore_in_main = require'terrain.spawn_ores'.clear_ore_in_main
local generate_additional_rocks = require 'terrain.rocks'
local mixed_ore = require 'terrain.mixed_ore'
local generate_river = require'terrain.river'.generate
local draw_spawn_area = require 'terrain.spawn_area'

local Terrain = {}

Terrain.is_spawn_circle = require'terrain.spawn_circle'.contains
Terrain.is_river = require'terrain.river'.contains

function Terrain.draw_structures()
    local surface = game.surfaces[global.bb_surface_name]
    local team_directions = TerrainParams.team_directions
    for _, direction in pairs(team_directions) do draw_spawn_area(surface, nil, direction) end
    for _, direction in pairs(team_directions) do clear_ore_in_main(surface, direction) end
    for _, direction in pairs(team_directions) do generate_additional_rocks(surface, nil, direction) end
    for _, direction in pairs(team_directions) do generate_spawn_ore(surface, nil, direction) end
    for _, direction in pairs(team_directions) do generate_silo(surface, nil, direction) end
    draw_spawn_circle(surface)
end


function Terrain.generate(event)

    local surface = event.surface
    local left_top = event.area.left_top
    local left_top_x = left_top.x
    local left_top_y = left_top.y

    if TerrainParams.debug or false then
        for y = 0, 31, 1 do
            for x = 0, 31, 1 do
                local pos = {x = left_top_x + x, y = left_top_y + y}
                if Terrain.is_spawn_circle(surface, nil, pos) then
                    TerrainDebug.tile_spawner(surface, pos)
                end
                if Terrain.is_river(surface, nil, defines.direction.east, pos) then
                    TerrainDebug.tile_river(surface, pos)
                end
                if Terrain.is_river(surface, nil, defines.direction.west, pos) then
                    TerrainDebug.tile_river(surface, pos)
                end
            end
        end
    end

    mixed_ore(surface, nil, left_top_x, left_top_y)
    local river_directions = TerrainParams.river.directions
    for _, direction in pairs(river_directions) do generate_river(surface, nil, direction, left_top) end
end


return Terrain
