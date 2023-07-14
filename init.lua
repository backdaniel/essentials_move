essentials_move = {}

local modpath = minetest.get_modpath("essentials_move")

local S = minetest.get_translator("essentials_move")

-- UMBRELLA

minetest.register_tool("essentials_move:umbrella", {
	description = S("Umbrella"),
	inventory_image = "tool_umbrella.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
	end,
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


