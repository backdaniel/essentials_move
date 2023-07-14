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
        local pos = user:get_pos()
        
        pos.x = math.floor(pos.x + 0.5)
        pos.z = math.floor(pos.z + 0.5)

        local CHUNK_SIZE = 100

        local vm = minetest.get_voxel_manip()

        for y = 31000, -31000, -CHUNK_SIZE do
            local pos1 = {x = pos.x, y = math.max(y - CHUNK_SIZE + 1, -31000), z = pos.z}
            local pos2 = {x = pos.x, y = y, z = pos.z}

            local emin, emax = vm:read_from_map(pos1, pos2)
            local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
            local data = vm:get_data()

            for cy = emax.y, emin.y, -1 do
                local vi = area:index(pos.x, cy, pos.z)
                local nodename = minetest.get_name_from_content_id(data[vi])

                if nodename ~= "air" and nodename ~= "ignore" then
                    pos.y = cy + 1
                    user:set_pos(pos)
                    return
                end
            end
        end
    end
})

-- TELEPORT


