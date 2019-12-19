local Session = require 'utils.session_data'

local function admin_only_message(str)
	for _, player in pairs(game.connected_players) do
		if player.admin == true then
			player.print("Admins-only-message: " .. str, {r=0.88, g=0.88, b=0.88})
		end
	end
end

local jail_messages = {
	"You´re done bud!",
	"Busted!"
}

local function jail(target_player, source_player)
	local source = source_player.name or 'Server'
	local permission_group = game.permissions.get_group("prisoner")
	if not permission_group then
		permission_group = game.permissions.create_group("prisoner")
		for action_name, _ in pairs(defines.input_action) do
			permission_group.set_allows_action(defines.input_action[action_name], false)
		end
		permission_group.set_allows_action(defines.input_action.write_to_console, true)
		permission_group.set_allows_action(defines.input_action.gui_click, true)
		permission_group.set_allows_action(defines.input_action.gui_selection_state_changed, true)
	end
	permission_group.add_player(target_player.name)
	game.print(target_player.name .. " has been jailed. " .. jail_messages[math.random(1, #jail_messages)], { r=0.98, g=0.66, b=0.22})
	admin_only_message(target_player.name .. " was jailed by " .. source)
end

local freedom_messages = {
	"Yaay!",
	"Welcome back!"
}
local function free(target_player, source_player)
	local source = source_player.name or 'Server'
	local permission_group = game.permissions.get_group("Default")
	permission_group.add_player(target_player.name)
	game.print(target_player.name .. " was set free from jail. " .. freedom_messages[math.random(1, #freedom_messages)], { r=0.98, g=0.66, b=0.22})
	admin_only_message(source .. " set " .. target_player.name .. " free from jail")
end

commands.add_command(
    'jail',
    'Sends the player to gulag!',
    function(cmd)
        local trusted = Session.get_trusted_table()
        local player = game.player
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not player.admin then
                    p("You're not admin!", {r = 1, g = 0.5, b = 0.1})
                    return
                end
            end

            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if target_player then
                trusted[target_player.name] = false
                jail(target_player, player)
            end
        else
            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if target_player then
                trusted[target_player.name] = false
                jail(target_player, 'Server')
            end
        end
    end
)

commands.add_command(
    'unjail',
    'Brings back the player from gulag.',
    function(cmd)
        local player = game.player
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not player.admin then
                    p("You're not admin!", {r = 1, g = 0.5, b = 0.1})
                    return
                end
            end

            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if target_player then
                free(target_player, player)
            end
        else
            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if target_player then
                free(target_player, 'Server')
            end
        end
    end
)