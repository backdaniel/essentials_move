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
                itemstack:add_wear(30)
                player:set_wielded_item(itemstack)

                player:set_physics_override({gravity=0, speed=2})

                local velocity = player:get_velocity()
                local goal = -2.3
                local difference = goal - velocity.y
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



-- TELEPORT


