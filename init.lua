minetest.register_chatcommand("afk", {
    description = "Tell everyone you are afk.",
	privs = {interact=true},
    func = function ( name, param )
        local player = minetest.get_player_by_name(name)
        minetest.chat_send_all(name.." is AFK! "..param)
        return true
    end,
})

minetest.register_chatcommand("spawn", {
	params = "",
	description = "Teleport to the spawn point.",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		if spawn_spawnpos then
			player:setpos(spawn_spawnpos)
			return true, "Teleporting to spawn..."
		else
			return false, "The spawn point is not set!"
		end
	end,
})

minetest.register_chatcommand("setspawn", {
	params = "",
	description = "Sets the spawn point to your current position.",
	privs = { server=true },
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local pos = player:getpos()
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local pos_string = x..","..y..","..z
		local pos_string_2 = "Setting spawn point to ("..x..", "..y..", "..z..")"
		minetest.setting_set("static_spawnpoint",pos_string)
		spawn_spawnpos = pos
		minetest.setting_save()
		return true, pos_string_2
	end,
})

minetest.register_chatcommand("rbc", {
    description = "who built it?",
    privs = {ismod = true},
    func = function( name, param)
        local cmd_def = minetest.chatcommands["rollback_check"]
        if cmd_def then
            minetest.chat_send_player(name, "Punch a node to ID builder...")
            cmd_def.func(name, "rollback_check 1 100000000")
        end
        return false
    end,
    })


minetest.register_chatcommand("roll", {
    description = "Demote & rollback Player",
    privs = {ismod = true},
    func = function( name, param)
        minetest.chat_send_all("Player "..param.." has privs removed, and all their work is being removed from the game.")
        local privs = {}
        --minetest.get_player_privs(param)
        privs.shout = 1
        minetest.set_player_privs(param, privs)
        minetest.rollback_revert_actions_by("player:"..param, 100000000)
        return false
    end,
    })

-- roll on 0.5.0, with modname:foo.lua syntax
local pre = "worldscript"
local wp = minetest.get_worldpath() .. "/"
-- intentional global assignment
worldpath = wp

local byhand = {
  oddly_breakable_by_hand = 3,
}


local e = minetest.chat_send_all
local rightclick = function(...)
  local path = wp.."worldscript.lua"
  local f, err = loadfile(path)
  if not f then
    e("can't run world script: "..err)
  else
    f(...)
  end
end

minetest.register_node("lamby:worldscript", {
  description = "Worldscript block",
  tiles = {"worldscript.png"},
  groups = byhand,
  on_rightclick = rightclick,
})

minetest.register_chatcommand("die", {
    description = "That kill you. ;-)",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local invref = player:get_inventory()
        if invref:is_empty("main") then
            if invref:is_empty("craft") then
                player:setpos(spawn)
                player:set_hp(20)
            else
                player:set_hp(0)
                minetest.chat_send_player(name, "If you are not in the spawn type /die again.")
            end
        else
            player:set_hp(0)
            minetest.chat_send_player(name, "If you are not in the spawn type /die again.") 
        end
    end
})