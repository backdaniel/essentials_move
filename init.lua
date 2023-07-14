essentials_move = {}

local modpath = minetest.get_modpath("essentials_move")

local S = minetest.get_translator("essentials_move")

-- UMBRELLA

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

                itemstack:add_wear(100)

                local wear = itemstack:get_wear()
                local playername = player:get_player_name()
                minetest.chat_send_all("Player " .. playername .. " used the umbrella. Current wear: " .. wear)

                player:set_wielded_item(itemstack)

                local velocity = player:get_velocity()
                player:set_physics_override({gravity=0})
                velocity.y = 0
                player:set_velocity(velocity)
            else
                player:set_physics_override({gravity=1})
            end
        else
            player:set_physics_override({gravity=1})
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



-- TELEPORT


