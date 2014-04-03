doors = {}

--{{{ Functions

--{{{ can_open for door with bolt
doors.can_open_bolted = function (pos, node, clicker)
    if string.find(node.name, "_1") then
        local door_facedir = node.param2
        local clicker_facedir = minetest.dir_to_facedir(vector.direction(clicker:getpos(),pos))
        if door_facedir ~= clicker_facedir then return false
        end
    end
    return true
end
--}}}

--{{{ swap_door
doors.swap_door = function (pos, dir, check_name, replace, replace_dir, params, meta)
    pos.y = pos.y+dir
    if not minetest.get_node(pos).name == check_name then
        return
    end

	local p2 = minetest.get_node(pos).param2
	p2 = params[p2+1]
		
    minetest.swap_node(pos, {name=replace_dir, param2 = p2})

    pos.y = pos.y-dir
    minetest.swap_node(pos, {name=replace, param2 = p2})

    if meta ~= nil then
        local metadata = minetest.get_meta(pos)
        metadata:set_string(meta[1], meta[2])

        pos.y = pos.y+dir

        metadata = minetest.get_meta(pos)
        meta:set_string(meta[1], meta[2])
    end
end
--}}}

--{{{ open_door
doors.open_door = function (pos, name)
    local part = name:sub(-3)
    name = name:sub(0,-5)

    if part == "t_1" then
        doors.swap_door(pos,-1, name.."_b_1", name.."_t_2", name.."_b_2", {1,2,3,0})
    elseif part == "b_1" then
        doors.swap_door(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
    elseif part == "t_2" then
        doors.swap_door(pos,-1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
    elseif part == "b_2" then
        doors.swap_door(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
    end
end
--}}}

--{{{ rightclick_on_locked
doors.rightclick_on_locked = function(pos, node, clicker, wield_item)
    if real_locks.can_open_locked (pos, wield_item) then
        doors.open_door(pos, node.name)
    end
end
--}}}

--{{{ rightclock_on_bolted
doors.rightclick_on_bolted = function(pos, node, clicker)
    if doors.can_open_bolted(pos, node, clicker) then
        doors.open_door(pos, node.name)
    end
end
--}}}

--{{{ rightclick_on_lockable
doors.rightclick_on_lockable = function (pos, node, clicker, wield_item)
    if wield_item:get_name() == "real_locks:lock" then
        doors.swap_door(pos, 1, name.."_t_1",
            name.."locked_b_1", name.."locked_t_1",
            {"lock_pass", wield_item:get_metadata()}
        )
        wield_item:take_item()
    else
        doors.open_door(pos, node.name)
    end
end
--}}}

--{{{ rightclick_on_not_lockable
doors.rightclick_on_not_lockable = function (pos, node)
    doors.open_door(pos, node.name)
end
--}}}
--}}}

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
			
			local passwd = itemstack:get_metadata()
			if passwd ~= nil then
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

    if def.rightclick == nil then
        def.rightclick = doors.rightclick_on_not_lockable
    end
	
    --{{{ Node registration

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
		
		on_rightclick = def.rightclick,
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
		
		on_rightclick = def.rightclick,
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
		
		on_rightclick = def.rightclick,
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
		
		on_rightclick = def.rightclick,
	})
    --}}}

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

--}}}

minetest.register_alias("doors:door_wood_a_c", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_a_o", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_b_c", "doors:door_wood_b_1")
minetest.register_alias("doors:door_wood_b_o", "doors:door_wood_b_1")
