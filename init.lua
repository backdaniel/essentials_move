movement_essentials = {}

local modpath = minetest.get_modpath("movement_essentials")

local S = minetest.get_translator("movement_essentials")

-- HELPERS

local function is_creative(player_name)
	local player_privs = minetest.get_player_privs(player_name)
	return player_privs.creative or minetest.is_creative_enabled(player_name)
end

-- UMBRELLA

local UMBRELLA_MOVE_SPEED = 2
local UMBRELLA_FALL_SPEED = -2.3
local UMBRELLA_WEAR_VALUE = 20

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

local gliding = false
minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local def = player:get_physics_override()
		local itemstack = player:get_wielded_item()
		if itemstack:get_name() == "movement_essentials:umbrella" and can_glide(player) then
			gliding = true
			if not is_creative(player:get_player_name()) then
				itemstack:add_wear(UMBRELLA_WEAR_VALUE)
				player:set_wielded_item(itemstack)
			end
			player:set_physics_override({gravity=0, speed=UMBRELLA_MOVE_SPEED})
			local velocity = player:get_velocity()
			local difference = UMBRELLA_FALL_SPEED - velocity.y
			local scaled = 2 / (1 + math.exp(-difference)) - 1
			player:add_velocity({x=0, y=scaled, z=0})
		elseif gliding then
			player:set_physics_override({gravity=1, speed=1})
			gliding = false
		end
	end
end)

minetest.register_tool("movement_essentials:umbrella", {
	description = S("Umbrella"),
	inventory_image = "tool_umbrella.png",
	stack_max = 1,
})

minetest.register_craft({
	output = "movement_essentials:umbrella",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"", "default:stick", ""},
		{"", "default:stick", ""},
	}
})


-- RECALL

local MIN_DISTANCE = 20

minetest.override_item("default:mese_crystal", {
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local spawn
		local current_pos = user:get_pos()

		if minetest.get_modpath("beds") and beds.spawn and beds.spawn[name] then
			spawn = beds.spawn[name]
		else
			spawn = minetest.setting_get_pos("static_spawnpoint")
		end

		if spawn then
			if vector.distance(current_pos, spawn) >= MIN_DISTANCE then
				user:set_pos(spawn)
				minetest.chat_send_all(name .. " used Mese Crystal to recall.")
				if not is_creative(name) then
					itemstack:take_item()
				end
				return itemstack
			else
				minetest.chat_send_player(name, "You are too close to the spawn point!")
				return itemstack
			end
		else
			minetest.chat_send_player(name, "No available spawn point!")
			return itemstack
		end
	end
})

-- TELEPORT

local texture = minetest.registered_items["default:mese_crystal_fragment"].inventory_image

minetest.register_entity("movement_essentials:shard", {
	physical = true,
	collide_with_objects = false,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5},
	textures = {texture},
	on_step = function(self, dtime, moveresult)
		if moveresult.collides and moveresult.collisions[1] and moveresult.collisions[1].type == "node" then
			local pos = self.object:get_pos()
			for _, player in ipairs(minetest.get_connected_players()) do
				if player:get_player_name() == self.thrower then
					player:set_pos(pos)
					self.object:remove()
					return
				end
			end
		end
	end,
})

minetest.override_item("default:mese_crystal_fragment", {
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local playerpos = user:get_pos()
		local obj = minetest.add_entity({
			x = playerpos.x,
			y = playerpos.y + user:get_properties().eye_height,
			z = playerpos.z,
		}, "movement_essentials:shard")
		local dir = user:get_look_dir()
		obj:set_velocity({x = dir.x * 20, y = dir.y * 20, z = dir.z * 20})
		obj:set_acceleration({x = 0, y = -8, z = 0})
		obj:get_luaentity().thrower = name
		if not is_creative(name) then
			itemstack:take_item()
		end
		return itemstack
	end
})
