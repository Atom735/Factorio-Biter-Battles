local TerrainUtils = {}

local function table_shuffle_table(t, rand)
    local iterations = #t
    if iterations == 0 then
        error('Not a sequential table')
        return
    end
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end


function TerrainUtils.get_replacement_tile_name(surface, seed, pos)

    local rand = game.create_random_generator(seed + pos.x * 7 + pos.y * 11 + 32)
    for i = 1, 128, 1 do
        local vectors = {{0, i}, {0, i * -1}, {i, 0}, {i * -1, 0}}
        table_shuffle_table(vectors, rand)
        for _, v in pairs(vectors) do
            local tile = surface.get_tile(pos.x + v[1], pos.y + v[2])
            if not tile.collides_with('resource-layer') then
                if tile.name ~= 'stone-path' then return tile.name end
            end
        end
    end
    return 'grass-1'
end


return TerrainUtils
