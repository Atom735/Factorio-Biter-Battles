local GuiElements = require 'gui.elements'
local GuiRegistrator = require 'gui.registrator'
local GuiFactory = {}


function GuiFactory.window(player, caption, closable)

	local gui = player.gui.screen
	local frame = gui.add{type = 'frame', direction = 'vertical'}

	local title_flow = frame.add{type = 'flow', direction = 'horizontal'}
	title_flow.style.horizontally_stretchable = true
	title_flow.style.horizontal_spacing = 8

	local title_label = title_flow.add{type = 'label', caption = caption or '%CAPTION%', style = 'frame_title'}
	title_label.drag_target = frame

	local title_pusher = title_flow.add{type = 'empty-widget', style = 'draggable_space_header'}
	title_pusher.style.height = 24
	title_pusher.style.horizontally_stretchable = true
	title_pusher.drag_target = frame

    if closable then
	    local title_close_button = title_flow.add{type = 'sprite-button', style = 'frame_action_button', sprite = 'utility/close_white'}
    end
end

local map_params = {

}

function GuiFactory.next_round_params(player)

    local gui = player.gui.screen
    local frame = GuiElements.preview_frame[player.index]
    if not (frame and frame.valid) then
      frame = gui.add({type = 'frame', caption = {'setup-frame'}, direction = 'vertical'})
      frame.auto_center = true
      frame.style.horizontal_align = 'right'
      frame.style.maximal_height = player.display_resolution.height / player.display_scale
      frame.style.vertically_stretchable = true
      GuiElements.preview_frame[player.index] = frame
    end
    refresh_preview_gui(player)
end

function zzz()

    local player = game.player
    local admin = player.admin
    local gui = player.gui.screen
    gui.clear()

	local frame = gui.add{type = 'frame', direction = 'vertical'}

	local title_flow = frame.add{type = 'flow', direction = 'horizontal'}
	title_flow.style.horizontally_stretchable = true
	title_flow.style.horizontal_spacing = 8

	local title_label = title_flow.add{type = 'label', caption = {'gui-map-generator.title'}, style = 'frame_title'}
	title_label.drag_target = frame

	local title_pusher = title_flow.add{type = 'empty-widget', style = 'draggable_space_header'}
	title_pusher.style.height = 24
	title_pusher.style.horizontally_stretchable = true
	title_pusher.drag_target = frame

	local title_close_button = title_flow.add{type = 'sprite-button', style = 'frame_action_button', sprite = 'utility/close_white'}

    local actions_flow = frame.add{type = 'flow', direction = 'horizontal'}
	actions_flow.style.horizontally_stretchable = true
	actions_flow.style.horizontal_spacing = 8

	local actions_pusher = title_flow.add{type = 'empty-widget', style = 'draggable_space_header'}
	actions_pusher.style.height = 24
	actions_pusher.style.horizontally_stretchable = true
	actions_pusher.drag_target = frame

    if admin then
        local action_preview_button = actions_flow.add{type = 'button', caption = {'gui-map-generator.show-preview'}, style = 'map_generator_preview_button'}
    end
    local action_confirm_button = actions_flow.add{type = 'button', caption = {'gui.close'}, style = 'map_generator_confirm_button'}
end


return GuiFactory
