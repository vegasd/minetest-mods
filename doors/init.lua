doors = {}

--{{{ doors:register_door
function doors:register_door(name, def)
	def.groups.not_in_creative_inventory = 1
	
    --{{{ Door nodeboxes
	local box = {{-0.5, -0.5, -0.5,   0.5, 0.5, -0.5+3/16}}

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
	
    --{{{ Item registration
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
			
			if def.with_lock then
			    local passwd = itemstack:get_metadata()
			    local meta = minetest.get_meta(pt)
			    meta:set_string("lock_pass", passwd)
			    meta:set_string("infotext", def.infotext)
			    meta = minetest.get_meta(pt2)
			    meta:set_string("lock_pass", passwd)
			    meta:set_string("infotext", def.infotext)
			end
			
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
	})
    --}}}
	
	local tt = def.tiles_top
	local tb = def.tiles_bottom
	
	local function after_dig_node(pos, name)
		if minetest.get_node(pos).name == name then
			minetest.remove_node(pos)
		end
	end
	
    --{{{ On rightclick
	local function swapDoor(pos, dir, check_name, replace, replace_dir, lock)
		pos.y = pos.y+dir
		if not minetest.get_node(pos).name == check_name then
			return
		end
		
		minetest.swap_node(pos, {name=replace_dir})
		
		pos.y = pos.y-dir
		minetest.swap_node(pos, {name=replace})

        if lock ~= nil then
            local meta = minetest.get_meta(pos)
            meta:set_string("lock_pass", lock)

		    pos.y = pos.y+dir

            meta = minetest.get_meta(pos)
            meta:set_string("lock_pass", lock)
        end
	end

    if not def.can_open then
        def.can_open = function (pos, clicker)
            local wield_item = clicker:get_wielded_item()
            if wield_item:get_name() == "real_locks:key" then 
		        local lock_pass = minetest.get_meta(pos):get_string("lock_pass")
		        local key_pass = wield_item:get_metadata()

		        return lock_pass == key_pass
            else
                return false
            end
	    end
    end
    --}}}
	
    --{{{ Node registration
    if def.with_lock then

    --{{{ b_1
	minetest.register_node(name.."_b_1_locked", {
		tiles = {tb[1], tb[3], tb[2], tb[2].."^[transformr180", tb[1], tb[1].."^[transformfx"},
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
			after_dig_node(pos, name.."_t_1_locked")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if def.can_open(pos, clicker) then
			    openDoor(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2")
			end
		end,
	})
    --}}}
	
    --{{{ t_1
	minetest.register_node(name.."_t_1_locked", {
		tiles = {tt[3].."^[transformr180", tt[2], tt[2], tt[2].."^[transformr180", tt[1], tt[1].."^[transformfx"},
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
			after_dig_node(pos, name.."_b_1_locked")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if def.can_open(pos, clicker) then
			    openDoor(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2")
			end
		end,
	})
    --}}}
	
    --{{{ b_2
	minetest.register_node(name.."_b_2_locked", {
		tiles = {tb[1], tb[3].."^[transformfy", tb[2].."^[transformfx", tb[2], tb[1].."^[transformfx", tb[1]},
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
			after_dig_node(pos, name.."_t_2_locked")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if def.can_open(pos, clicker) then
			    openDoor(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1")
			end
		end,
	})
    --}}}
	
    --{{{ t_2
	minetest.register_node(name.."_t_2_locked", {
		tiles = {tt[3], tt[2], tt[2].."^[transformfx", tt[2], tt[1].."^[transformfx", tt[1]},
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
			after_dig_node(pos, name.."_b_2_locked")
		end,
		
		on_rightclick = function(pos, node, clicker)
			if def.can_open(pos, clicker) then
			    openDoor(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1")
			end
		end,
	})
    --}}}

	else

    --{{{ b_1
	minetest.register_node(name.."_b_1", {
		tiles = {tb[1], tb[3], tb[2], tb[2].."^[transformr180", tb[1], tb[1].."^[transformfx"},
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
            wield_item = clicker:get_wielded_item()
            if wield_item:get_name() == "real_locks:lock" then
                swapDoor(pos, 1, name.."_t_1",
                    name.."_b_1_locked", name.."_t_1_locked",
                    wield_item:get_metadata()
                )
                wield_item:take_item()
            else
			    openDoor(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2")
            end
		end,
	})
    --}}}
	
    --{{{ t_1
	minetest.register_node(name.."_t_1", {
		tiles = {tt[3].."^[transformr180", tt[2], tt[2], tt[2].."^[transformr180", tt[1], tt[1].."^[transformfx"},
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
            local wield_item = clicker:get_wielded_item():get_name()
            if wield_item == "real_locks:lock" then
                swapDoor(pos, 1, name.."_b_1",
                    name.."_t_1_locked", name.."_b_1_locked",
                    wield_item:get_metadata()
                )
                wield_item:take_item()
            else
			    openDoor(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2")
            end
		end,
	})
    --}}}
	
    --{{{ b_2
	minetest.register_node(name.."_b_2", {
		tiles = {tb[1], tb[3].."^[transformfy", tb[2].."^[transformfx", tb[2], tb[1].."^[transformfx", tb[1]},
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
            local wield_item = clicker:get_wielded_item():get_name()
            if wield_item == "real_locks:lock" then
                swapDoor(pos, 1, name.."_t_2",
                    name.."_b_2_locked", name.."_t_2_locked",
                    wield_item:get_metadata()
                )
                wield_item:take_item()
            else
			    openDoor(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1")
            end
		end,
	})
    --}}}
	
    --{{{ t_2
	minetest.register_node(name.."_t_2", {
		tiles = {tt[3], tt[2], tt[2].."^[transformfx", tt[2], tt[1].."^[transformfx", tt[1]},
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
            local wield_item = clicker:get_wielded_item():get_name()
            if wield_item == "real_locks:lock" then
                swapDoor(pos, 1, name.."_b_2",
                    name.."_t_2_locked", name.."_b_2_locked",
                    wield_item:get_metadata()
                )
                wield_item:take_item()
            else
			    openDoor(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1")
            end
		end
	})
    --}}}

    end
    --}}}
end
--}}}

--{{{ Various doors registration
-- wooden door
doors:register_door("doors:door_wood", {
	description = "Wooden Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"door_wood_b.png", "door_wood_c.png","door_wood_d.png"},
	tiles_top = {"door_wood_a.png", "door_wood_c.png","door_wood_d.png"},
})

minetest.register_craft({
	output = "doors:door_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

-- Strong wooden door
doors:register_door("doors:door_wood_iron_frame", {
	description = "Strong wooden Door with iron frame",
	inventory_image = "door_wood_if.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"door_wood_if_b.png", "door_wood_if_c.png","door_wood_if_d.png"},
	tiles_top = {"door_wood_if_a.png", "door_wood_if_c.png","door_wood_if_d.png"},
})

minetest.register_craft({
	output = "doors:door_wood_iron_frame",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

-- Weak wooden door
doors:register_door("doors:door_wood_weak", {
	description = "Weak wooden door",
	inventory_image = "door_wood_weak.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"door_wood_weak_b.png", "door_wood_weak_c.png","door_wood_weak_d.png"},
	tiles_top = {"door_wood_weak_a.png", "door_wood_weak_c.png","door_wood_weak_d.png"},
})

minetest.register_craft({
	output = "doors:door_wood_weak",
	recipe = {
		{"group:wood", ""},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})


-- Ordinary steel door
doors:register_door("doors:door_steel", {
	description = "Steel door",
	inventory_image = "door_steel.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles_bottom = {"door_steel_b.png", "door_steel_c.png", "door_steel_d.png"},
	tiles_top = {"door_steel_a.png", "door_steel_c.png", "door_steel_d.png"},
	only_placer_can_open = true,
})

minetest.register_craft({
	output = "doors:door_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})

-- Jail door
doors:register_door("doors:door_steel_jail", {
	description = "Jail steel door",
	inventory_image = "door_steel_jail.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles_bottom = {"door_steel_jail_b.png", "door_steel_jail_c.png", "door_steel_jail_d.png"},
	tiles_top = {"door_steel_jail_a.png", "door_steel_jail_c.png", "door_steel_jail_d.png"},
	only_placer_can_open = true,
})

minetest.register_craft({
	output = "doors:door_steel_jail",
	recipe = {
		{"default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})

-- Beautiful steel door
doors:register_door("doors:door_steel_bl", {
	description = "Beautiful steel door",
	inventory_image = "door_steel_bl.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles_bottom = {"door_steel_bl_b.png", "door_steel_bl_c.png", "door_steel_bl_d.png"},
	tiles_top = {"door_steel_bl_a.png", "door_steel_bl_c.png", "door_steel_bl_d.png"},
	only_placer_can_open = true,
})

minetest.register_craft({
	output = "doors:door_steel_bl",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", ""}
	}
})
--}}}

minetest.register_alias("doors:door_wood_a_c", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_a_o", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_b_c", "doors:door_wood_b_1")
minetest.register_alias("doors:door_wood_b_o", "doors:door_wood_b_1")
