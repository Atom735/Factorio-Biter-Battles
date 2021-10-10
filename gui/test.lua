
local max_seed = 2^32 - 2
local initial_seed = 2390375328

local surface_origin = {}
local mgs_empty = {
    seed = initial_seed,
    width = 512,
    height = 512,
}
local forces_mod_params = {
    ['NS'] = {
        preview_surface = {},
    },
    ['EW'] = {
        preview_surface = {},
    },
    ['NE'] = {
        preview_surface = {},
    },
    ['NW'] = {
        preview_surface = {},
    },
    ['NS4'] = {
        preview_surface = {},
    },
    ['NE4'] = {
        preview_surface = {},
    },
}

local map_gen_votes = {
    ['default'] = {
        forces_mod = 'NS',
    },
}
local players_raitings = {
    ['default'] = 1.0,
}

script.on_init(function ()
    surface_origin = game.surfaces['nauvis']
    for key, value in pairs(forces_mod_params) do
        value.preview_surface = game.surfaces[key] or game.create_surface(key, mgs_empty)
        value.preview_surface.generate_with_lab_tiles = true
    end
end)

local get_random_seed = function()
    return (32452867 * game.tick) % max_seed
end

local is_reasonable_seed = function(string)
    local number = tonumber(string)
    if not number then return end
    if number < 0 or number > max_seed then
        return
    end
    return true
end

local players = function(index)
    return (index and game.get_player(index)) or game.players
end


local gui_actions = {}
local gui_elements = {
    map_generator = {},
}
local gui_functions = {}

local function deregister_gui(gui)
    local player_gui_actions = gui_actions[gui.player_index]
    if not player_gui_actions then return end
    player_gui_actions[gui.index] = nil
    for k, child in pairs (gui.children) do
        deregister_gui(child)
    end
end
local function register_gui_action(gui, param)
    local player_gui_actions = gui_actions[gui.player_index]
    if not player_gui_actions then
        gui_actions[gui.player_index] = {}
        player_gui_actions = gui_actions[gui.player_index]
    end
    player_gui_actions[gui.index] = param
end

local function generic_gui_event(event)
    local gui = event.element
    if not (gui and gui.valid) then return end

    local player_gui_actions = gui_actions[gui.player_index]
    if not player_gui_actions then return end

    local action = player_gui_actions[gui.index]
    if not action then return end

    if not gui_functions[action.type] then
        game.print('WARN: [ActionType](' .. action.type .. ') not registered', {0.7, 0, 0, 1})
        return
    end
    gui_functions[action.type](event, action)
end


script.on_event(defines.events.on_gui_click, generic_gui_event)
script.on_event(defines.events.on_gui_selection_state_changed, generic_gui_event)
script.on_event(defines.events.on_gui_text_changed, generic_gui_event)
script.on_event(defines.events.on_gui_confirmed, generic_gui_event)
script.on_event(defines.events.on_gui_checked_state_changed, generic_gui_event)
script.on_event(defines.events.on_gui_selected_tab_changed, generic_gui_event)




local gui_elements_map_generator = gui_elements.map_generator

local function refresh_map_gen_gui_seed(player)
    local subheader = gui_elements_map_generator[player.index].subheader
    if not (subheader and subheader.valid) then return end
    deregister_gui(subheader)
    subheader.clear()

    local admin = player.admin

    local seed_flow = subheader.add{type = "flow", direction = "horizontal", style = "player_input_horizontal_flow"}
    seed_flow.add{type = "label", style = "caption_label", caption = {"gui-map-generator.map-seed"}}
    if admin then
        local seed_input = seed_flow.add{
            type = "textfield", text = surface_origin.map_gen_settings.seed, style = "long_number_textfield",
            numeric = true, allow_decimal = false, allow_negative = false
        }
        register_gui_action(seed_input, {type = "map_gen_check_seed_input"})
        local shuffle_button = seed_flow.add{type = "sprite-button", sprite = "utility/shuffle", style = "tool_button"}
        register_gui_action(shuffle_button, {type = "map_gen_shuffle_button"})
    else
        seed_flow.add{type = "label", style = "caption_label", caption = surface_origin.map_gen_settings.seed}
    end
end

local function refresh_map_gen_gui_forces_force_item(player, forces_mod)
    local forces_votes = gui_elements_map_generator[player.index].forces_votes
    if not forces_votes then return end
    local frame = forces_votes[forces_mod]
    if not (frame and frame.valid) then return end
    deregister_gui(frame)
    frame.clear()

    local mod_params = forces_mod_params[forces_mod]

    local column = frame.add{type='flow', direction ='vertical'}
    column.style.horizontally_stretchable = true
    local label = column.add{
        type = 'label',
        style = 'frame_title',
        caption = {'map_gen_gui.'..forces_mod},
    }
    label.style.single_line = false
    label.style.width = 256

    local votes = 0.0
    local style = 'map_generator_preview_button'
    local d = 0
    for key, map_gen_vote in pairs( map_gen_votes) do
        d = d + players_raitings[key]
        if map_gen_vote.forces_mod == forces_mod then
            votes = votes + players_raitings[key]
            if key == player.index then
                style = 'map_generator_confirm_button'
            end
        end
    end
    votes = votes / d * 100.0

    local vote_button = column.add{
        type = 'button',
        style = style,
        caption = string.format("%.2f %%", votes),
    }
    vote_button.style.width = 256
    register_gui_action(vote_button, {type = "map_gen_forces_mod_vote", player = player, forces_mod = forces_mod})
    local minimap = frame.add{type = 'minimap', surface_index = 1 or mod_params.preview_surface.index,}
    minimap.style.size = 192

end


local function refresh_map_gen_gui_forces_force_items_all(player)
    for key, value in pairs(forces_mod_params) do
        refresh_map_gen_gui_forces_force_item(player, key)
    end
end

local function refresh_map_gen_gui_forces(player)
    local frame = gui_elements_map_generator[player.index].forces
    if not (frame and frame.valid) then return end
    deregister_gui(frame)
    frame.clear()

    local table = frame.add{
        type = 'table',
        column_count = 2,
        style = 'bordered_table',
    }

    gui_elements_map_generator[player.index].forces_votes = {}
    for key, value in pairs(forces_mod_params) do
        gui_elements_map_generator[player.index].forces_votes [key] = table.add{type='flow', direction ='horizontal'}
    end
    refresh_map_gen_gui_forces_force_items_all(player)
end


local function refresh_map_gen_gui_resources(player)
    local frame = gui_elements_map_generator[player.index].resources
    if not (frame and frame.valid) then return end
    deregister_gui(frame)
    frame.clear()

    local table = frame.add{
        type = 'table',
        column_count = 4,
        style = 'bordered_table',
    }
    local mgs = surface_origin.map_gen_settings
    local autoplace_controls = mgs.autoplace_controls
    for key, value in pairs(autoplace_controls) do
        local title_flow = table.add{type='flow', direction='horizontal'}
        -- local sprite
        -- if (not sprite) and game.is_valid_sprite_path('entity/'..key) then
        --     sprite = title_flow.add{type='sprite', sprite  = 'entity/'..key}
        -- end
        -- if (not sprite) and game.is_valid_sprite_path('item/'..key) then
        --     sprite = title_flow.add{type='sprite', sprite  = 'item/'..key}
        -- end
        -- if (not sprite) and game.is_valid_sprite_path('fluid/'..key) then
        --     sprite = title_flow.add{type='sprite', sprite  = 'fluid/'..key}
        -- end
        -- if (not sprite) and game.is_valid_sprite_path(key) then
        --     sprite = title_flow.add{type='sprite', sprite  = key}
        -- end
        local title = title_flow.add{type='label', caption = {'entity-name.'..key}, style = 'map_gen_row_label'}

        local frequency_flow = table.add{type='flow', direction='vertical'}
        local frequency_slide = frequency_flow.add{
            type='slider',style = 'map_generator_13_notch_slider',
            minimum_value = 0,
            maximum_value = 6,
            value_step = 1/6,
        }
        frequency_flow.add{
            type='slider', style = 'map_generator_13_notch_slider',enabled = false, ignored_by_interaction = true,
            minimum_value = 0,
            maximum_value = 6,
            value_step = 1/6,
        }

        local size_flow = table.add{type='flow', direction='vertical'}
        local size_slide = size_flow.add{
            type='slider',style = 'map_generator_13_notch_slider',
            minimum_value = 0,
            maximum_value = 6,
            value_step = 1/6,
        }
        size_flow.add{
            type='slider',style = 'map_generator_13_notch_slider',  enabled = false, ignored_by_interaction = true,
            minimum_value = 0,
            maximum_value = 6,
            value_step = 1/6,
        }

        local richness_flow = table.add{type='flow', direction='vertical'}
        local richness_slide = richness_flow.add{
            type='slider', style = 'map_generator_13_notch_slider',
            minimum_value = 0,
            maximum_value = 6,
            value_step = 1/6,
        }
        richness_flow.add{
            type='slider', style = 'map_generator_13_notch_slider', enabled = false, ignored_by_interaction = true,
            minimum_value = 0,
            maximum_value = 6,
            value_step = 1/6,
        }
    end
end

local function refresh_map_gen_gui(player)
    local frame = gui_elements_map_generator[player.index].frame
    if not (frame and frame.valid) then return end
    deregister_gui(frame)
    frame.clear()

    local admin = player.admin
    local surface = player.surface

    if not (surface and surface.valid) then return end

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
    register_gui_action(title_close_button, {type = "close", element = frame})

    local inner = frame.add{type = "frame", style = "inside_deep_frame", direction = "vertical"}.add{type = "flow", direction = "vertical"}
    inner.style.vertical_spacing = 0

    local subheader = inner.add{type = "frame", style = "subheader_frame"}
    subheader.style.horizontally_stretchable = true

    gui_elements_map_generator[player.index].subheader = subheader
    refresh_map_gen_gui_seed(player)

    local tabbed_pane = inner.add{type = 'tabbed-pane'}
    local tab_forces = tabbed_pane.add{type="tab", caption={'gui-map-editor-title.force-editor'}}
    local tab_forces_frame = tabbed_pane.add{type="frame", style = 'window_content_frame_in_tabbed_panne', direction = 'vertical'}
    tab_forces_frame.style.horizontally_stretchable = true
    tabbed_pane.add_tab(tab_forces, tab_forces_frame)
    gui_elements_map_generator[player.index].forces = tab_forces_frame
    refresh_map_gen_gui_forces(player)

    local tab_resources = tabbed_pane.add{type="tab", caption={'gui-map-generator.resources-tab-title'}}
    local tab_resources_frame = tabbed_pane.add{type="frame", style = 'window_content_frame_in_tabbed_panne', direction = 'vertical'}
    tab_resources_frame.style.horizontally_stretchable = true
    tabbed_pane.add_tab(tab_resources, tab_resources_frame)
    gui_elements_map_generator[player.index].resources = tab_resources_frame
    refresh_map_gen_gui_resources(player)

    local tab_terrain = tabbed_pane.add{type="tab", caption={'gui-map-generator.terrain-tab-title'}}
    local tab_terrain_frame = tabbed_pane.add{type="frame", style = 'window_content_frame_in_tabbed_panne', direction = 'vertical'}
    tab_terrain_frame.style.horizontally_stretchable = true
    tabbed_pane.add_tab(tab_terrain, tab_terrain_frame)
    gui_elements_map_generator[player.index].terrain = tab_terrain_frame

    local tab_enemy = tabbed_pane.add{type="tab", caption={'gui-map-generator.enemy-tab-title'}}
    local tab_enemy_frame = tabbed_pane.add{type="frame", style = 'window_content_frame_in_tabbed_panne', direction = 'vertical'}
    tab_enemy_frame.style.horizontally_stretchable = true
    tabbed_pane.add_tab(tab_enemy, tab_enemy_frame)
    gui_elements_map_generator[player.index].enemy = tab_enemy_frame

    local tab_advanced = tabbed_pane.add{type="tab", caption={'gui-map-generator.advanced-tab-title'}}
    local tab_advanced_frame = tabbed_pane.add{type="frame", style = 'window_content_frame_in_tabbed_panne', direction = 'vertical'}
    tab_advanced_frame.style.horizontally_stretchable = true
    tabbed_pane.add_tab(tab_advanced, tab_advanced_frame)
    gui_elements_map_generator[player.index].advanced = tab_advanced_frame

    tabbed_pane.selected_tab_index = 1

    local actions_flow = frame.add{type = 'flow', direction = 'horizontal'}
    actions_flow.style.horizontally_stretchable = true
    actions_flow.style.horizontal_spacing = 8

    local actions_pusher = actions_flow.add{type = 'empty-widget', style = 'draggable_space_header'}
    actions_pusher.style.height = 24
    actions_pusher.style.horizontally_stretchable = true
    actions_pusher.drag_target = frame

    if admin then
        local action_preview_button = actions_flow.add{type = 'button', caption = {'gui-map-generator.show-preview'}, style = 'map_generator_preview_button'}
        register_gui_action(action_preview_button, {type = "map_gen_preview"})
    end
    local action_confirm_button = actions_flow.add{type = 'button', caption = {'gui.close'}, style = 'map_generator_confirm_button'}
    register_gui_action(action_confirm_button, {type = "close", element = frame})
end

local function make_map_gen_gui(player)
    local gui = player.gui.screen
    local frame = gui_elements_map_generator[player.index]
    if not (frame and frame.valid) then
        frame = gui.add{type = 'frame', direction = 'vertical'}
        frame.auto_center = true
        frame.style.horizontal_align = "right"
        frame.style.maximal_height = player.display_resolution.height / player.display_scale
        frame.style.vertically_stretchable = true
        gui_elements_map_generator[player.index] = {
            frame = frame,
        }
    end
    refresh_map_gen_gui(player)
end










function gui_functions.map_gen_shuffle_button(event, param)
    local mgs = surface_origin.map_gen_settings
    mgs.seed  = get_random_seed()
    surface_origin.map_gen_settings = mgs
    for k, player in pairs (players()) do
        refresh_map_gen_gui_seed(player)
    end
end

function gui_functions.map_gen_check_seed_input(event, param)
    local gui = event.element
    if not (gui and gui.valid) then return end
    if not is_reasonable_seed(gui.text) then return end
    gui.style = "long_number_textfield"
    if event.name == defines.events.on_gui_confirmed then
        local mgs = surface_origin.map_gen_settings
        mgs.seed  = tonumber(gui.text)
        surface_origin.map_gen_settings = mgs
        for k, player in pairs (players()) do
            refresh_map_gen_gui_seed(player)
        end
    end
end

function gui_functions.map_gen_preview(event, param)
    surface_origin.clear();
end

function gui_functions.close(event, param)
    local gui = param.element
    deregister_gui(gui)
    if not (gui and gui.valid) then return end
    gui.destroy()
end

function gui_functions.map_gen_forces_mod_vote(event, param)
    local gui = event.element
    if not (gui and gui.valid) then return end
    local player = param.player
    local forces_mod = param.forces_mod
    if not map_gen_votes[player.index] then map_gen_votes[player.index] = {} end
    map_gen_votes[player.index].forces_mod = forces_mod
    for key, player in pairs(game.players) do
        refresh_map_gen_gui_forces_force_items_all(player)
    end
end



script.on_nth_tick(60, function() game.forces['player'].chart_all() end)
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    if not players_raitings[player.index] then
        players_raitings[player.index] = players_raitings.default*10
    end
    player.gui.screen.clear()
    make_map_gen_gui(player)
end)
