essentials_move = {}

local modpath = minetest.get_modpath("essentials_move")

local S = minetest.get_translator("essentials_move")

-- UMBRELLA

local UMBRELLA_MOVE_SPEED = 2
local UMBRELLA_FALL_SPEED = -2.3
local UMBRELLA_WEAR_VALUE = 30

local function can_glide(user)
    local pos = user:get_pos()
    pos.y = pos.y - 0.1
    local node_below = minetest.get_node(pos)
    local velocity = user:get_velocity()
    if node_below.name == 'air' and not user:get_attach() and velocity.y < 0 then
        return true
    else
        return false
    end
end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        if player:get_wielded_item():get_name() == "essentials_move:umbrella" then
            if can_glide(player) then
                local itemstack = player:get_wielded_item()
                itemstack:add_wear(UMBRELLA_WEAR_VALUE)
                player:set_wielded_item(itemstack)

                player:set_physics_override({gravity=0, speed=UMBRELLA_MOVE_SPEED})

                local velocity = player:get_velocity()
                local difference = UMBRELLA_FALL_SPEED - velocity.y
                local scaled = 2 / (1 + math.exp(-difference)) - 1
                player:add_velocity({x=0, y=scaled, z=0})
            else
                player:set_physics_override({gravity=1, speed=1})
            end
        else
            player:set_physics_override({gravity=1, speed=1})
        end
    end
end)

minetest.register_tool("essentials_move:umbrella", {
    description = S("Umbrella"),
    inventory_image = "tool_umbrella.png",
    stack_max = 1,
})

minetest.register_craft({
    output = "essentials_move:umbrella",
    recipe = {
        {"default:paper", "default:paper", "default:paper"},
        {"", "default:stick", ""},
        {"", "default:stick", ""},
    }
})

-- RECALL

local function is_creative(player_name)
  local player_privs = minetest.get_player_privs(player_name)
  return player_privs.creative or minetest.is_creative_enabled(player_name)
end

minetest.override_item("default:mese_crystal", {
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        local spawn

        if beds and beds.spawn and beds.spawn[name] then
            spawn = beds.spawn[name]
        else
            spawn = minetest.setting_get_pos("static_spawnpoint")
        end

        if spawn then
            user:set_pos(spawn)
            minetest.chat_send_all(name .. " used Mese Crystal to recall.")
            if not is_creative(name) then
                itemstack:take_item()
            end
            user:set_hp(user:get_hp() - 6)
            return itemstack
        else
            minetest.chat_send_player(name, "No available spawn point!")
            return itemstack
        end
    end
})

-- TELEPORT


