local GuiActions = require 'gui.actions'

local GuiRegistrator = {}

function GuiRegistrator.deregister(gui)
    local player_gui_actions = GuiActions[gui.player_index]
    if not player_gui_actions then return end
    player_gui_actions[gui.index] = nil
    for k, child in pairs (gui.children) do
        GuiRegistrator.deregister(child)
    end
end

return GuiRegistrator
