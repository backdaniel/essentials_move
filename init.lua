essentials_move = {}

local modpath = minetest.get_modpath("essentials_move")

local S = minetest.get_translator("essentials_move")

-- UMBRELLA

local function can_glide(user)
    local pos = user:get_pos()
    pos.y = pos.y - 1
    local node = minetest.get_node(pos)

    if node.name == "air" then
        return false
    end
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef and nodedef.liquidtype ~= "none" then
        return false
    end
    if user:get_attach() then
        return false
    end
    return true
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
            end
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


