local DirectionTranslation = require 'map.direction_translation'

local Public = {
    ['NS' ] = {
        tile_origin_pos = function (pos)
            if pos.y >= 0 then
                return DirectionTranslation.I
            end
            if global.bb_map_params.reflect_rotate then
                return DirectionTranslation.R_180
            else
                return DirectionTranslation.M_V
            end
        end,
        distance_to_main_side = function (pos)
            return pos.y
        end,
    },
    ['EW' ] = {
        tile_origin_pos = function (pos)
            if pos.x >= 0 then
                return DirectionTranslation.I
            end
            if global.bb_map_params.reflect_rotate then
                return DirectionTranslation.R_180
            else
                return DirectionTranslation.M_H
            end
        end,
        distance_to_main_side = function (pos)
            return pos.x
        end,
    },
    ['NE' ] = {
        tile_origin_pos = function (pos)
            if pos.x - pos.y >= 0 then
                return DirectionTranslation.I
            end
            if global.bb_map_params.reflect_rotate then
                return DirectionTranslation.R_180
            else
                return DirectionTranslation.M_NE
            end
        end,
        distance_to_main_side = function (pos)
            return pos.x - pos.y
        end,
    },
    ['NW' ]  = {
        tile_origin_pos = function (pos)
            if pos.x + pos.y + 1 >= 0 then
                return DirectionTranslation.I
            end
            if global.bb_map_params.reflect_rotate then
                return DirectionTranslation.R_180
            else
                return DirectionTranslation.M_NW
            end
        end,
        distance_to_main_side = function (pos)
            return pos.x + pos.y + 1
        end,
    },
    ['NS4'] = {
        tile_origin_pos = function (pos)
            if pos.x - pos.y >= 0 then
                if pos.x + pos.y + 1 >= 0 then
                    return DirectionTranslation.I
                end
                if global.bb_map_params.reflect_rotate then
                    return DirectionTranslation.R_180
                else
                    return DirectionTranslation.M_NW
                end
            end
            if global.bb_map_params.reflect_rotate then
                return DirectionTranslation.R_180
            else
                return DirectionTranslation.M_NE
            end
        end,
        distance_to_main_side = function (pos)
            return pos.y - pos.x
        end,
    },
    ['NE4'] = {
        tile_origin_pos = function (pos)
            if pos.y >= 0 then
                if pos.x >= 0 then
                    return DirectionTranslation.I
                end
                if global.bb_map_params.reflect_rotate then
                    return DirectionTranslation.R_90_CCW
                else
                    return DirectionTranslation.M_H
                end
            end
            if global.bb_map_params.reflect_rotate then
                return DirectionTranslation.R_90_CW
            else
                return DirectionTranslation.M_V
            end
        end,
        distance_to_main_side = function (pos)
            return pos.y
        end,
    },
}
Public['EW4'] = Public['NS4']
Public['NW4'] = Public['NE4']

return Public
