local generic_gui_event = require 'gui.events'


local lib = {}

lib.events =
{
    -- [defines.events.on_chunk_generated] = on_chunk_generated,
    -- [defines.events.on_entity_died] = on_entity_died,

    [defines.events.on_gui_click] = generic_gui_event,
    [defines.events.on_gui_selection_state_changed] = generic_gui_event,
    [defines.events.on_gui_text_changed] = generic_gui_event,
    [defines.events.on_gui_confirmed] = generic_gui_event,
    [defines.events.on_gui_checked_state_changed] = generic_gui_event,

    -- [defines.events.on_player_died] = on_player_died,
    -- [defines.events.on_pre_player_died] = on_pre_player_died,

    -- [defines.events.on_player_demoted] = refresh_player_gui_event,
    -- [defines.events.on_player_display_resolution_changed] = refresh_player_gui_event,
    -- [defines.events.on_player_display_scale_changed] = refresh_player_gui_event,
    -- [defines.events.on_player_promoted] = refresh_player_gui_event,

    -- [defines.events.on_player_joined_game] = on_player_joined_game,
    -- [defines.events.on_player_changed_force] = on_player_changed_force,
    -- [defines.events.on_player_respawned] = on_player_respawned,
    -- [defines.events.on_rocket_launched] = on_rocket_launched,
    -- [defines.events.on_script_path_request_finished] = on_script_path_request_finished,
    -- --[defines.events.on_ai_command_completed] = on_ai_command_completed,
    -- [defines.events.on_tick] = on_tick,

    -- [defines.events.on_technology_effects_reset] = on_technology_effects_reset
}

lib.on_nth_tick =
{
--   [13] = chart_base_area
}


lib.on_event = function(event)
    -- local action = events[event.name]
    -- if not action then return end
    -- return action(event)
end

lib.on_load = function()
    -- script_data = global.wave_defense or script_data
    -- add_remote_interface()
end

lib.on_init = function()
    -- global.wave_defense = global.wave_defense or script_data
    -- on_init()
    -- add_remote_interface()
end

lib.on_configuration_changed = function(data)
-- for name, upgrade in pairs (get_upgrades()) do
--   script_data.team_upgrades[name] = script_data.team_upgrades[name] or 0
-- end

-- for k, player in pairs (game.players) do
--   update_upgrade_listing(player)
-- end

-- init_map_settings()
-- set_recipes(game.forces.player)
-- game.forces.player.disable_research()

-- if script_data.surface and script_data.surface.valid then
--   script_data.path_request_queue = {}
--   script_data.spawner_path_requests = {}
--   for k, spawner in pairs (script_data.surface.find_entities_filtered{type = "unit-spawner"}) do
--     request_path_for_spawner(spawner)
--   end
-- end

-- if type(script_data.difficulty.wave_power_function) ~= "string" then
--   script_data.difficulty.wave_power_function = "default"
-- end

-- if type(script_data.difficulty.speed_multiplier_function) ~= "string" then
--   script_data.difficulty.speed_multiplier_function  = "default"
-- end

end
return lib;
