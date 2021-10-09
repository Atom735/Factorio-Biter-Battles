
--[[
    @EN Directional reflection tables

    @RU Таблицы отражения направлений

    @Links: https://docs.google.com/presentation/d/1LbDrXFSKcYfGazDrFr8X_o2M61s9n65Bfl4F35eAfrY/edit?usp=sharing
--]]
local Public = {
    I = {
	    [defines.direction.north    ] = defines.direction.north    ,
	    [defines.direction.northeast] = defines.direction.northeast,
	    [defines.direction.east     ] = defines.direction.east     ,
	    [defines.direction.southeast] = defines.direction.southeast,
	    [defines.direction.south    ] = defines.direction.south    ,
	    [defines.direction.southwest] = defines.direction.southwest,
	    [defines.direction.west     ] = defines.direction.west     ,
	    [defines.direction.northwest] = defines.direction.northwest,
        chunk_pos = function (pos)
            return {x = pos.x, y = pos.y}
        end,
        entity_pos = function (pos)
            return {x = pos.x, y = pos.y}
        end,
    },
    --[[
        @EN Vertical reflection

        @RU Отражение по вертикали
    --]]
    M_V = {
	    [defines.direction.north    ] = defines.direction.south    ,
	    [defines.direction.northeast] = defines.direction.southeast,
	    [defines.direction.east     ] = defines.direction.east     ,
	    [defines.direction.southeast] = defines.direction.northeast,
	    [defines.direction.south    ] = defines.direction.north    ,
	    [defines.direction.southwest] = defines.direction.northwest,
	    [defines.direction.west     ] = defines.direction.west     ,
	    [defines.direction.northwest] = defines.direction.southwest,
        chunk_pos = function (pos)
            return {x = pos.x, y = -pos.y-1}
        end,
        entity_pos = function (pos)
            return {x = pos.x, y = -pos.y}
        end,
    },
    --[[
        @EN Horizontal reflection

        @RU Отражение по горизонтали
    --]]
    M_H = {
	    [defines.direction.north    ] = defines.direction.north    ,
	    [defines.direction.northeast] = defines.direction.northwest,
	    [defines.direction.east     ] = defines.direction.west     ,
	    [defines.direction.southeast] = defines.direction.southwest,
	    [defines.direction.south    ] = defines.direction.south    ,
	    [defines.direction.southwest] = defines.direction.southeast,
	    [defines.direction.west     ] = defines.direction.east     ,
	    [defines.direction.northwest] = defines.direction.northeast,
        chunk_pos = function (pos)
            return {x = -pos.x-1, y = pos.y}
        end,
        entity_pos = function (pos)
            return {x = -pos.x, y = pos.y}
        end,
    },
    --[[
        @EN Reflection on the diagonal Northwest

        @RU Отражение по диагонали Северо-Запад
    --]]
    M_NW = {
	    [defines.direction.north    ] = defines.direction.east     ,
	    [defines.direction.northeast] = defines.direction.northeast,
	    [defines.direction.east     ] = defines.direction.north    ,
	    [defines.direction.southeast] = defines.direction.northwest,
	    [defines.direction.south    ] = defines.direction.west     ,
	    [defines.direction.southwest] = defines.direction.southwest,
	    [defines.direction.west     ] = defines.direction.south    ,
	    [defines.direction.northwest] = defines.direction.southeast,
        chunk_pos = function (pos)
            return {x = -pos.y-1, y = -pos.x-1}
        end,
        entity_pos = function (pos)
            return {x = -pos.y, y = -pos.x}
        end,
    },
    --[[
        @EN Diagonal Reflection Northeast

        @RU Отражение по диагонали Северо-Восток
    --]]
    M_NE = {
	    [defines.direction.north    ] = defines.direction.west     ,
	    [defines.direction.northeast] = defines.direction.southwest,
	    [defines.direction.east     ] = defines.direction.south    ,
	    [defines.direction.southeast] = defines.direction.southeast,
	    [defines.direction.south    ] = defines.direction.east     ,
	    [defines.direction.southwest] = defines.direction.northeast,
	    [defines.direction.west     ] = defines.direction.north    ,
	    [defines.direction.northwest] = defines.direction.northwest,
	    [defines.direction.northwest] = defines.direction.southeast,
        chunk_pos = function (pos)
            return {x = pos.y, y = pos.x}
        end,
        entity_pos = function (pos)
            return {x = pos.y, y = pos.x}
        end,
    },
    --[[
        @EN Rotate direction 90 degrees counterclockwise

        @RU Поворот направления на 90 градусов против часовой стрелки
    --]]
    R_90_CCW = {
	    [defines.direction.north    ] = defines.direction.west     ,
	    [defines.direction.northeast] = defines.direction.northwest,
	    [defines.direction.east     ] = defines.direction.north    ,
	    [defines.direction.southeast] = defines.direction.northeast,
	    [defines.direction.south    ] = defines.direction.east     ,
	    [defines.direction.southwest] = defines.direction.southeast,
	    [defines.direction.west     ] = defines.direction.south    ,
	    [defines.direction.northwest] = defines.direction.southwest,
        chunk_pos = function (pos)
            return {x = pos.y, y = -pos.x-1}
        end,
        entity_pos = function (pos)
            return {x = pos.y, y = -pos.x}
        end,
    },
    --[[
        @EN Rotate direction 90 degrees clockwise

        @RU Поворот направления на 90 градусов по часовой стрелки
    --]]
    R_90_CW = {
        [defines.direction.north    ] = defines.direction.east     ,
        [defines.direction.northeast] = defines.direction.southeast,
        [defines.direction.east     ] = defines.direction.south    ,
        [defines.direction.southeast] = defines.direction.southwest,
        [defines.direction.south    ] = defines.direction.west     ,
        [defines.direction.southwest] = defines.direction.northwest,
        [defines.direction.west     ] = defines.direction.north    ,
        [defines.direction.northwest] = defines.direction.northeast,
        chunk_pos = function (pos)
            return {x = -pos.y-1, y = pos.x}
        end,
        entity_pos = function (pos)
            return {x = -pos.y, y = pos.x}
        end,
    },
    --[[
        @EN Rotate direction 180 degrees clockwise

        @RU Поворот направления на 180 градусов
    --]]
    R_180 = {
        [defines.direction.north    ] = defines.direction.south    ,
        [defines.direction.northeast] = defines.direction.southwest,
        [defines.direction.east     ] = defines.direction.west     ,
        [defines.direction.southeast] = defines.direction.northwest,
        [defines.direction.south    ] = defines.direction.north    ,
        [defines.direction.southwest] = defines.direction.northeast,
        [defines.direction.west     ] = defines.direction.east     ,
        [defines.direction.northwest] = defines.direction.southeast,
        chunk_pos = function (pos)
            return {x = -pos.x-1, y = -pos.y-1}
        end,
        entity_pos = function (pos)
            return {x = -pos.x, y = -pos.y}
        end,
    },
}
return Public
