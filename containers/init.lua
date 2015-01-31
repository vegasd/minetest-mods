containers = {
    ["containers:chest"] =        { w = 9, h = 3 },
    ["containers:chest_locked"] = { w = 9, h = 3 },
    ["containers:wood_bin"] =        { w = 5, h = 3 },
    ["containers:wood_bin_locked"] = { w = 5, h = 3 },
    ["containers:wood_jbox"] =        { w = 3, h = 2 },
    ["containers:wood_jbox_locked"] = { w = 3, h = 2 },
    y_offset = 0.2,
    inventory_margin = 0.72,
    hotbar_margin = 0.23,
}

--{{{ Functions

local function get_container_formspec(pos, name)
    -- Prepare coord of metadata
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z

    -- Add aliases for container inventory width and height
    local w,h = containers[name].w, containers[name].h

    -- Get label for container inventory
    local label = minetest.registered_nodes[name].description

    -- Calculate formspec width and height
    local form_w = math.max(inventory.width, w)
    local form_h = inventory.height + h + 1

    -- Calculate offset for container inventory
    local x_offset = (inventory.width - w)/2
    local y_offset = containers.y_offset

    -- Calculate player inventory position,
    -- player hotbar position and "Inventory" label position
    local inv_y = h + y_offset + containers.inventory_margin
    local label_y = inv_y - y_offset - 0.4

    -- Construct formspec string
    local formspec =
        "size["..form_w..","..form_h.."]"..
        "label[0,-0.4;"..label.."]"..
        "label[0,"..label_y..";Inventory]"..
        default.gui_bg..
        default.gui_bg_img..
        default.gui_slots..
        "list[nodemeta:"..spos..";main;"..
            x_offset..","..y_offset..";"..
            w..","..h..
            ";]"..
        inventory.main(0, inv_y)
    return formspec
end

local function construct_container(pos)
    -- Get node name
    local name = minetest.get_node(pos).name

    -- Set node infotext equal to it's description (name)
    local meta = minetest.get_meta(pos)
    meta:set_string("infotext", minetest.registered_nodes[name].description)

    -- Set node inventory size
    local inv = meta:get_inventory()
    inv:set_size("main", containers[name].w * containers[name].h)
end

local function handle_unlocked_container(pos, node, clicker, wield_item)
    if wield_item:get_name() == "real_locks:lock" then
        -- Change unlocked container to locked,
        -- keeping all it's metadata (infotext, inventory etc.)
        node.name = node.name .. "_locked"
        minetest.swap_node(pos, node)

        local meta = minetest.get_meta(pos)
        -- Changing locked containter infotext
        -- back to it's normal value
        -- (not this one from unlocked container)
		meta:set_string("infotext", minetest.registered_nodes[node.name].description)

        -- Now set's the password (lock)
        minetest.get_meta(pos):set_string("lock_pass", wield_item:get_metadata())

        -- And take used lock
        wield_item:take_item()
    else
        -- Open container
		minetest.log("action",
            clicker:get_player_name()..
            " open "..
            node.name:sub(12,-1)..
            " at "..
            minetest.pos_to_string(pos))

        minetest.show_formspec(
			clicker:get_player_name(),
			node.name,
			get_container_formspec(pos, node.name)
		)
    end
end

local function handle_locked_container(pos, node, clicker, wield_item)
    -- If wield item is not a key, than character just cant open the container.
    if wield_item:get_name() == "real_locks:key" then
        -- Get lock metadata and key metadata
        local password = minetest.get_meta(pos):get_string("lock_pass")
        local meta = wield_item:get_metadata()

        -- If lock metadata and key metadata is equal,
        -- than open the container
        if meta == password then
            minetest.show_formspec(
                clicker:get_player_name(),
                node.name,
                get_container_formspec(pos, node.name)
            )
        end
    end
end

local function dig_container(pos, oldnode, oldmeta, digger)
    -- Drop all what was inside the container
    for k, itemstack in ipairs(oldmeta.inventory.main) do
        if not itemstack:is_empty() then
            pos.y = pos.y + 0.5
            minetest.add_item(pos, itemstack)
        end
    end

    -- If character dig the chest with bare hands,
    -- than he is just lift it (or something like that)
    if digger:get_wielded_item():get_name() == "" then
        
        -- If this was a locked container,
        -- than we need to save lock password
        if oldmeta.fields.lock_pass ~= nil then
            local container = ItemStack({
                name = oldnode.name,
                count = 1,
                wear = 0,
                metadata = oldmeta.fields.lock_pass
            })
            digger:set_wielded_item(container)
        else
            digger:set_wielded_item(oldnode.name)
        end
    end
end

local function place_locked_container(pos, placer, itemstack)
    -- When we place a locked container,
    -- we must restore it's lock password
    local meta = minetest.get_meta(pos)
    local password = itemstack:get_metadata()
    meta:set_string("lock_pass", password)
end
--}}}

--{{{ Chest

--{{{ unlocked
minetest.register_node("containers:chest", {
	description = "Chest",
	tiles = {
        "default_chest_top.png", "default_chest_top.png",
        "default_chest_side.png", "default_chest_side.png",
        "default_chest_side.png", "default_chest_front.png"
    },
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
    drop = "",

	on_construct = construct_container,
    after_dig_node = dig_container,
    on_rightclick = handle_unlocked_container,
    --{{{ Logging
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
    --}}}
})
--}}}

--{{{ locked
minetest.register_node("containers:chest_locked", {
	description = "Locked chest",
	tiles = {
        "default_chest_top.png", "default_chest_top.png",
        "default_chest_side.png", "default_chest_side.png",
        "default_chest_side.png", "default_chest_front.png"
    },
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
    drop = "",

	on_construct = construct_container,
    after_place_node = place_locked_container,
    after_dig_node = dig_container,
    on_rightclick = handle_locked_container,
    --{{{ Logging
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
    --}}}
})
--}}}

--}}}

--{{{ Wooden bin
minetest.register_node("containers:wood_bin", {
	description = "Wooden bin",
	tiles = {"containers_wood_bin.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
    drop = "",

	on_construct = construct_container,
    after_dig_node = dig_container,
    on_rightclick = handle_unlocked_container,
    --{{{ Logging
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in bin at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to bin at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from bin at "..minetest.pos_to_string(pos))
	end,
    --}}}
})

minetest.register_node("containers:wood_bin_locked", {
	description = "Locked wooden bin",
	tiles = {"containers_wood_bin.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
    drop = "",

	on_construct = construct_container,
    after_place_node = place_locked_container,
    after_dig_node = dig_container,
    on_rightclick = handle_locked_container,
    --{{{ Logging
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in bin at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to bin at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from bin at "..minetest.pos_to_string(pos))
	end,
    --}}}
})
--}}}

--{{{ Wooden jewelry box
minetest.register_node("containers:wood_jbox", {
	description = "Wooden jewelry box",
    --{{{ Tiles
	tiles = {
        "default_wood.png^containers_wood_jbox_top.png",
        "default_wood.png^containers_wood_jbox_top.png",
        "default_wood.png^containers_wood_jbox_side2.png",
        "default_wood.png^containers_wood_jbox_side.png",
        "default_wood.png^containers_wood_jbox_back.png",
        "default_wood.png^containers_wood_jbox_front.png"
    },
    --}}}
    paramtype = "light",
	paramtype2 = "facedir",
    drawtype = "nodebox",
    --{{{ Node box
    node_box = {
        type = "fixed",
        fixed = {
            -- "legs"
            {-6/16, -8/16, -1/16, -4/16, -7/16, -3/16},
            {-6/16, -8/16, 2/16, -4/16, -7/16, 4/16},
            {4/16, -8/16, -1/16, 6/16, -7/16, -3/16},
            {4/16, -8/16, 2/16, 6/16, -7/16, 4/16},
            -- Box
            {-5/16, -7/16, -2/16, 5/16, -3/16, 3/16},
            -- "head"
            {-4/16, -3/16, -1/16, 4/16, -2/16, 2/16},
            {-3/16, -2/16, 0, 3/16, -1/16, 1/16},
            -- "horns"
            {-4/16, -1/16, 0, -3/16, 0, 1/16},
            {-3/16, 0, 0, -2/16, 1/16, 1/16},
            {3/16, -1/16, 0, 4/16, 0, 1/16},
            {2/16, 0, 0, 3/16, 1/16, 1/16},
        }
    },
    --}}}
	groups = {choppy=2,oddly_breakable_by_hand=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
    drop = "",

	on_construct = construct_container,
    after_dig_node = dig_container,
    on_rightclick = handle_unlocked_container,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        -- If item is small, than you can put it in the small box
        if minetest.get_item_group(stack:get_name(), "small") > 0 then
            return stack:get_count()
        else
            return 0
        end
    end,
    --{{{ Logging
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in jewelry box at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to jewelry box at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from jewelry box at "..minetest.pos_to_string(pos))
	end,
    --}}}
})

minetest.register_node("containers:wood_jbox_locked", {
	description = "Locked wooden jewelry box",
    --{{{ Tiles
	tiles = {
        "default_wood.png^containers_wood_jbox_top.png",
        "default_wood.png^containers_wood_jbox_top.png",
        "default_wood.png^containers_wood_jbox_side2.png",
        "default_wood.png^containers_wood_jbox_side.png",
        "default_wood.png^containers_wood_jbox_back.png",
        "default_wood.png^containers_wood_jbox_front.png"
    },
    --}}}
    paramtype = "light",
	paramtype2 = "facedir",
    drawtype = "nodebox",
    --{{{ Node box
    node_box = {
        type = "fixed",
        fixed = {
            -- "legs"
            {-6/16, -8/16, -1/16, -4/16, -7/16, -3/16},
            {-6/16, -8/16, 2/16, -4/16, -7/16, 4/16},
            {4/16, -8/16, -1/16, 6/16, -7/16, -3/16},
            {4/16, -8/16, 2/16, 6/16, -7/16, 4/16},
            -- Box
            {-5/16, -7/16, -2/16, 5/16, -3/16, 3/16},
            -- "head"
            {-4/16, -3/16, -1/16, 4/16, -2/16, 2/16},
            {-3/16, -2/16, 0, 3/16, -1/16, 1/16},
            -- "horns"
            {-4/16, -1/16, 0, -3/16, 0, 1/16},
            {-3/16, 0, 0, -2/16, 1/16, 1/16},
            {3/16, -1/16, 0, 4/16, 0, 1/16},
            {2/16, 0, 0, 3/16, 1/16, 1/16},
        }
    },
    --}}}
	groups = {choppy=2,oddly_breakable_by_hand=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
    drop = "",

	on_construct = construct_container,
    after_place_node = place_locked_container,
    after_dig_node = dig_container,
    on_rightclick = handle_locked_container,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        -- If item is small, than you can put it in the small box
        if minetest.get_item_group(stack:get_name(), "small") > 0 then
            return stack:get_count()
        else
            return 0
        end
    end,
    --{{{ Logging
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in jewelry box at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to jewelry box at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from jewelry box at "..minetest.pos_to_string(pos))
	end,
    --}}}
})
--}}}
