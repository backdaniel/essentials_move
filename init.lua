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

minetest.override_item("default:mese_crystal", {
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        local pos = user:get_pos()
        local new_pos = {x=pos.x, y=0, z=pos.z}

        for y = 0, 2000, 16 do
            new_pos.y = y
            minetest.emerge_area({x=new_pos.x-16, y=new_pos.y, z=new_pos.z-16}, {x=new_pos.x+16, y=new_pos.y+16, z=new_pos.z+16})

            for i = 0, 15 do
                local y_check = y + i
                local pos_check = {x=new_pos.x, y=y_check, z=new_pos.z}
                local node = minetest.get_node(pos_check)
                local node_above = minetest.get_node({x=pos_check.x, y=pos_check.y+1, z=pos_check.z})
                local node_two_above = minetest.get_node({x=pos_check.x, y=pos_check.y+2, z=pos_check.z})

                if node.name ~= "air" and node_above.name == "air" and node_two_above.name == "air" then
                    new_pos.y = y_check + 1
                    minetest.after(0.1, function() 
                        minetest.chat_send_player(player_name, "Resurfacing...")
                        user:set_pos(new_pos)
                    end)
                    return
                end
            end
        end
    end
})

-- TELEPORT


