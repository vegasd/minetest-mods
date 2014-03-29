real_locks = {}
local NODEMETA_STR="lock_pass"

--{{{Set metadata

--{{{Crutch!!!
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "real_locks:keyform" then
        inv = player:get_inventory()
        for i, itemname in ipairs({"real_locks:lock", "real_locks:key"}) do
            local item = ItemStack({
                name = itemname,
                count = 1,
                wear = 0,
                metadata = fields.keymeta
            })
            inv:add_item("main", item)
            minetest.log("action",
                "player " ..player:get_player_name()..
                " crafts " ..item:to_string()
            )
        end
    end
end)

minetest.register_on_craft(function(result, player, old_craft_grid, inv)
    local name = result:get_name()
    if name == "real_locks:key" then
        minetest.show_formspec(player:get_player_name(), "real_locks:keyform", [[
            field[keymeta;Choose key form (password):;]
            ]])
        return ItemStack(nil)
    end
end)
--}}}

--}}}

--{{{Register door with lock
function real_locks:register_door(name, def)
    --{{{Copy from "doors" mod
	def.groups.not_in_creative_inventory = 1
	
	local box = {{-0.5, -0.5, -0.5,   0.5, 0.5, -0.5+1.5/8}}
	
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
    --}}}
	
    --{{{Item registration

    -- Add to register_on_craft check
    minetest.register_on_craft(function(result, player, old_craft_grid, inv)
        if result:get_name() == name then
            for i, item in ipairs(old_craft_grid) do
                if item:get_name() == "real_locks:lock" then
                    result:set_metadata(item:get_metadata())
                    return result
                end 
            end
        end
    end)

	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return itemstack
			end
			
			local ptu = pointed_thing.under
			local nu = minetest.get_node(ptu)
			if minetest.registered_nodes[nu.name].on_rightclick then
				return minetest.registered_nodes[nu.name].on_rightclick(ptu, nu, placer, itemstack)
			end
			
			local pt = pointed_thing.above
			local pt2 = {x=pt.x, y=pt.y, z=pt.z}
			pt2.y = pt2.y+1
			if
				not minetest.registered_nodes[minetest.get_node(pt).name].buildable_to or
				not minetest.registered_nodes[minetest.get_node(pt2).name].buildable_to or
				not placer or
				not placer:is_player()
			then
				return itemstack
			end
			
			local p2 = minetest.dir_to_facedir(placer:get_look_dir())
			local pt3 = {x=pt.x, y=pt.y, z=pt.z}
			if p2 == 0 then
				pt3.x = pt3.x-1
			elseif p2 == 1 then
				pt3.z = pt3.z+1
			elseif p2 == 2 then
				pt3.x = pt3.x+1
			elseif p2 == 3 then
				pt3.z = pt3.z-1
			end
			if not string.find(minetest.get_node(pt3).name, name.."_b_") then
				minetest.set_node(pt, {name=name.."_b_1", param2=p2})
				minetest.set_node(pt2, {name=name.."_t_1", param2=p2})
			else
				minetest.set_node(pt, {name=name.."_b_2", param2=p2})
				minetest.set_node(pt2, {name=name.."_t_2", param2=p2})
			end
			
			local passwd = itemstack:get_metadata()
			local meta = minetest.get_meta(pt)
			meta:set_string(NODEMETA_STR, passwd)
			meta:set_string("infotext", "Locked")
			meta = minetest.get_meta(pt2)
			meta:set_string(NODEMETA_STR, passwd)
			meta:set_string("infotext", "Locked")
			
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
	})
    --}}}

    --{{{Copy from "doors" mod (continue)
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
	
    if not def.can_open then
        def.can_open = function (pos, clicker)
            local wield_item = clicker:get_wielded_item()
            if wield_item:get_name() == "real_locks:key" then
		        local lock_pass = minetest.get_meta(pos):get_string(NODEMETA_STR)
		        local key_pass = wield_item:get_metadata()

		        return lock_pass == key_pass
            else
                return false
            end
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
			if def.can_open(pos, clicker) then
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
			if def.can_open(pos, clicker) then
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
			if def.can_open(pos, clicker) then
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
		
		on_rightclick = function(pos, node, clicker)
			if def.can_open(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
			end
		end,
	})
    --}}}
end

real_locks:register_door("real_locks:door_wood", {
	description = "Wooden Door with lock",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"door_wood_b.png", "door_brown.png"},
	tiles_top = {"door_wood_a.png", "door_brown.png"},
})

real_locks:register_door("real_locks:door_wood_bolt", {
	description = "Wooden Door with bolt",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"door_wood_b.png", "door_brown.png"},
	tiles_top = {"door_wood_a.png", "door_brown.png"},
    can_open = function (pos, clicker)
        print(minetest.get_node(pos).name)
        if string.find(minetest.get_node(pos).name, "_1") then
            local door_facedir = minetest.get_node(pos).param2
            local clicker_facedir = minetest.dir_to_facedir(vector.direction(clicker:getpos(),pos))
            if door_facedir ~= clicker_facedir then return false
            end
        end
        return true
    end
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
minetest.register_craft({
    type = "shapeless",
    output = "real_locks:door_wood",
    recipe = {
        "doors:door_wood",
        "real_locks:lock",
    },
})
--}}}
