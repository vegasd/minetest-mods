--{{{ Chest
minetest.register_node("containers:chest", {
	description = "Chest",
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
		meta:set_string("infotext", "Chest")
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
})
--}}}

--{{{ Wooden bin
minetest.register_node("containers:wood_bin", {
	description = "Wooden bin",
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
        
        -- Bin formspec
		meta:set_string("formspec",
	        "size[7,9]"..
	        default.gui_bg..
	        default.gui_bg_img..
	        default.gui_slots..
	        [[
            list[current_name;main;0,0.3;8,3;]
	        list[current_player;main;0,3.85;8,1;]
	        list[current_player;main;0,5.08;8,3;8]
            ]]..
	        default.get_hotbar_bg(0,3.85)
        )
		meta:set_string("infotext", "Bin")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*3)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
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
