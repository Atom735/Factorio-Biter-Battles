-- LuaFormatter off
local TerrainParams = {
    outer_circle = {
        radius = 39.0,
        noise = 10.0,
    },
    inner_circle = {
        radius = 9.5,
        sand = 7.0,
    },
    path_width = 5.0,
    fish_chance = 0.05,
    silo_distance = 84.0,
    silo_safe_area = 14.0,
    river = {
        radius = 22.0,
        noise = 11.0,
        curve_factor = 1.2,
        curve_noise = 5.1,
    },
    rocks_min_count = 24,
    spawn_ore = {
        -- Value "size" is a parameter used as coefficient for simplex noise
        -- function that is applied to shape of an ore patch. You can think of it
        -- as size of a patch on average. Recomended range is from 1 up to 50.

        -- Value "density" controls the amount of resource in a single tile.
        -- The center of an ore patch contains specified amount and is decreased
        -- proportionally to distance from center of the patch.

        -- Value "big_patches" and "small_patches" represents a number of an ore
        -- patches of given type. The "density" is applied with the same rule
        -- regardless of the patch size.
        ["iron-ore"] = {
            size = 23,
            density = 3500,
            big_patches = 2,
            small_patches = 1
        },
        ["copper-ore"] = {
            size = 21,
            density = 3000,
            big_patches = 1,
            small_patches = 2
        },
        ["coal"] = {
            size = 22,
            density = 2500,
            big_patches = 1,
            small_patches = 1
        },
        ["stone"] = {
            size = 20,
            density = 2000,
            big_patches = 1,
            small_patches = 0
        }
    },
    mixed_ores = {'copper-ore', 'iron-ore', 'stone', 'coal'},
    -- mixed_ore_multiplier order is based on the ores variable
    mixed_ore_multiplier = {1, 1, 1, 1},
}
-- LuaFormatter on

return TerrainParams
