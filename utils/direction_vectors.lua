-- LuaFormatter off
local direction_vectors = {
    [defines.direction.south    ] ={x = 0.000, y = 1.000},
    [defines.direction.southwest] ={x = 0.707, y = 0.707},
    [defines.direction.west     ] ={x = 1.000, y = 0.000},
    [defines.direction.northwest] ={x = 0.707, y =-0.707},
    [defines.direction.north    ] ={x = 0.000, y =-1.000},
    [defines.direction.northeast] ={x =-0.707, y =-0.707},
    [defines.direction.east     ] ={x =-1.000, y = 0.000},
    [defines.direction.southeast] ={x =-0.707, y = 0.707},
}
-- LuaFormatter on

return direction_vectors
