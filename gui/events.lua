GuiActions = require 'gui.actions'
GuiFunctions = require 'gui.functions'

local function generic_gui_event(event)
    local gui = event.element
    if not (gui and gui.valid) then return end

    local player_gui_actions = GuiActions[gui.player_index]
    if not player_gui_actions then return end

    local action = player_gui_actions[gui.index]
    if not action then return end

    GuiFunctions[action.type](event, action)
end

return generic_gui_event
