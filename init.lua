essentials_move = {}

local modpath = minetest.get_modpath("essentials_move")

local S = minetest.get_translator("essentials_move")

-- UMBRELLA

local function can_glide(user)
	return true
end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        if player:get_wielded_item():get_name() == "essentials_move:umbrella" then
            if can_glide(player) then
                local itemstack = player:get_wielded_item()

                itemstack:add_wear(200)

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


