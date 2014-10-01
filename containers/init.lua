-- TODO
INVENTORY_W = 8
INVENTORY_H = 4
CHEST_W = 8
CHEST_H = 4
BIN_W = 6
BIN_H = 3
Y_OFFSET = 0.2
INV_MARGIN = 0.72
HOTBAR_MARGIN = 0.23

--{{{ Functions

local function get_container_formspec(pos, name)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z

    local w,h = 0,0
    if name == "containers:chest" then
        w = CHEST_W
        h = CHEST_H
    elseif name == "containers:wood_bin" then
        w = BIN_W
        h = BIN_H
    end

    local label = minetest.registered_nodes[name].description

    local form_w = math.max(INVENTORY_W, w)
    local form_h = INVENTORY_H + h + 1

    local x_offset = (INVENTORY_W - w)/2
    local y_offset = Y_OFFSET

    local inv_y = h + y_offset + INV_MARGIN
    local label_y = inv_y - y_offset - 0.4
    local hb_y = inv_y + INVENTORY_H - 1 + HOTBAR_MARGIN

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
        "list[current_player;main;"..
            "0,"..inv_y..";"..
            INVENTORY_W..","..(INVENTORY_H-1)..
            ";]"..
        "list[current_player;main;"..
            "0,"..hb_y..";"..
            INVENTORY_W..",1;24]"..
        default.get_hotbar_bg(0,hb_y)
    --local formspec =
    --    "size[8,"..h.."]"..
    --    default.gui_bg..
    --    default.gui_bg_img..
    --    default.gui_slots..
    --    "list[nodemeta:".. spos .. ";main;0,0.3;8,4;]"..
    --    "list[current_player;main;0,4.85;8,3;]"..
    --    "list[current_player;main;0,8.08;8,1;24]"..
    --    default.get_hotbar_bg(0,4.85)
 return formspec
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
                get_chest_formspec(pos)
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

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", CHEST_W * CHEST_H)
	end,
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

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Locked chest")
		local inv = meta:get_inventory()
		inv:set_size("main", CHEST_W * CHEST_H)
	end,
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

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", BIN_W * BIN_H)
	end,
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
--}}}

--{{{ Wooden barrow
minetest.register_node("containers:barrow", {
	description = "Wooden barrow",
	tiles = {
        "default_chest_top.png", "default_chest_top.png",
        "default_chest_side.png", "default_chest_side.png",
        "default_chest_side.png", "default_chest_front.png"
    },
	groups = {choppy=2,oddly_breakable_by_hand=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
        
        -- Chest formspec
		meta:set_string("formspec",
	        "size[8,9]"..
	        default.gui_bg..
	        default.gui_bg_img..
	        default.gui_slots..
	        [[
            list[current_name;main;0,0.3;8,4;]
	        list[current_player;main;0,4.85;8,1;]
	        list[current_player;main;0,6.08;8,3;8]
            ]]..
	        default.get_hotbar_bg(0,4.85)
        )
		meta:set_string("infotext", "Barrow")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in barrow at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to barrow at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from barrow at "..minetest.pos_to_string(pos))
	end,
})
--}}}

--{{{ Wooden cabinet
minetest.register_node("containers:wood_cabinet", {
	description = "Wooden cabinet",
	tiles = {
        "default_chest_top.png", "default_chest_top.png",
        "default_chest_side.png", "default_chest_side.png",
        "default_chest_side.png", "default_chest_front.png"
    },
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
        
        -- Chest formspec
		meta:set_string("formspec",
	        "size[8,9]"..
	        default.gui_bg..
	        default.gui_bg_img..
	        default.gui_slots..
	        [[
            list[current_name;main;0,0.3;8,4;]
	        list[current_player;main;0,4.85;8,1;]
	        list[current_player;main;0,6.08;8,3;8]
            ]]..
	        default.get_hotbar_bg(0,4.85)
        )
		meta:set_string("infotext", "Cabinet")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in cabinet at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to cabinet at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from cabinet at "..minetest.pos_to_string(pos))
	end,
})
--}}}

--{{{ Wooden jewelry box
minetest.register_node("containers:wood_jbox", {
	description = "Wooden jewelry box",
	tiles = {
        "default_chest_top.png", "default_chest_top.png",
        "default_chest_side.png", "default_chest_side.png",
        "default_chest_side.png", "default_chest_front.png"
    },
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
        
        -- Chest formspec
		meta:set_string("formspec",
	        "size[8,9]"..
	        default.gui_bg..
	        default.gui_bg_img..
	        default.gui_slots..
	        [[
            list[current_name;main;0,0.3;8,4;]
	        list[current_player;main;0,4.85;8,1;]
	        list[current_player;main;0,6.08;8,3;8]
            ]]..
	        default.get_hotbar_bg(0,4.85)
        )
		meta:set_string("infotext", "Jewelry box")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
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
})
--}}}
