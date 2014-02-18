real_locks = {}
real_locks.meta = {}

--{{{Set metadata

--{{{Crutch!!!
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "real_locks:keyform" then
        real_locks.meta[player:get_player_name()] = fields.keymeta
    end
end)

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, inv)
    if itemstack:get_name() == "real_locks:key" then
        minetest.show_formspec(player:get_player_name(), "real_locks:keyform", [[
            field[keymeta;Choose key form (password):;]
            ]])
    end
end)
--}}}

minetest.register_on_craft(function(result, player, old_craft_grid, inv)
    local metainf = real_locks.meta[player:get_player_name()]
    result:set_metadata(metainf)
    inv:add_item("main", {
        name = "real_locks:lock",
        count = 1,
        wear = 0,
        metadata = metainf
    })
    print(result:get_metadata())
    real_locks.meta[player:get_player_name()] = nil

    return result
end)
--}}}

--{{{Register door with lock
function real_locks:register_door(name, def)
    --{{{Copy from "doors" mod but without item registration
	def.groups.not_in_creative_inventory = 1
	
	local box = {{-0.5, -0.5, -0.5,   0.5, 0.5, -0.5+1.5/16}}
	
	if not def.node_box_bottom then
		def.node_box_bottom = box
	end
	if not def.node_box_top then
		def.node_box_top = box
	end
	if not def.selection_box_bottom then
		def.selection_box_bottom= box
	end
	if not def.selection_box_top then
		def.selection_box_top = box
	end
	
	local tt = def.tiles_top
	local tb = def.tiles_bottom
	
	local function after_dig_node(pos, name)
		if minetest.get_node(pos).name == name then
			minetest.remove_node(pos)
		end
	end
	
	local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)
		pos.y = pos.y+dir
		if not minetest.get_node(pos).name == check_name then
			return
		end
		local p2 = minetest.get_node(pos).param2
		p2 = params[p2+1]
		
		minetest.swap_node(pos, {name=replace_dir, param2=p2})
		
		pos.y = pos.y-dir
		minetest.swap_node(pos, {name=replace, param2=p2})
	end
    --}}}
	
	local function check_player_priv(pos, player)
        if wield_item:get_name() == "real_locks:key" then
		    local lock_pass = minetest.get_meta(pos):get_string("lock_pass")
		    local key_pass = wield_item:get_metadata()

		    return lock_pass == key_pass
        else
            return false
        end
	end

	--{{{Node registration
	minetest.register_node(name.."_b_1", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1], tb[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_1")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker:get_wielded_item()) then
				on_rightclick(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
			end
		end,
	})
	
	minetest.register_node(name.."_t_1", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1], tt[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_1")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker:get_wielded_item()) then
				on_rightclick(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2", {1,2,3,0})
			end
		end,
	})
	
	minetest.register_node(name.."_b_2", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1].."^[transformfx", tb[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_2")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker:get_wielded_item()) then
				on_rightclick(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
			end
		end,
	})
	
	minetest.register_node(name.."_t_2", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1].."^[transformfx", tt[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_2")
		end,
		
		on_rightclick = function(pos, node, clicker:get_wielded_item())
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
			end
		end,
	})
    --}}}
end

real_locks:register_door("real_locks:door_wood", {
	description = "Wooden Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"door_wood_b.png", "door_brown.png"},
	tiles_top = {"door_wood_a.png", "door_brown.png"},
})
--}}}

--{{{Register keys and locks
minetest.register_craftitem("real_locks:key", {
    description = "Key",
    groups = {},
    inventory_image = "real_locks_key.png",
    wield_image = "real_locks_key.png",
    stack_max = 1,
    range = 2,
})

minetest.register_craftitem("real_locks:lock", {
    description = "Lock",
    groups = {},
    inventory_image = "real_locks_lock.png",
    wield_image = "real_locks_lock.png",
    stack_max = 1,
    range = 2,
})
--}}}

--{{{Craft recipes
minetest.register_craft({
    type = "shapeless",
    output = "real_locks:key",
    recipe = {
        "default:steel_ingot",
        "default:steel_ingot",
    },
})
--}}}
