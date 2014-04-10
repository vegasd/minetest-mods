doors = {}

--{{{ Default

--{{{ Tables

--{{{ Nodenames
local nodes = {
    "t_1", "b_1",
    "t_2", "b_2",

    "cw_t_1", "cw_b_1",
    "cw_t_2", "cw_b_2",
}
--}}}

--{{{ Nodeboxes
local box         = {-0.5,      -0.5, -0.5,  0.5,      0.5, -0.5+3/16}
local box_open    = {-0.5,      -0.5, -0.5, -0.5+3/16, 0.5,  0.5     }
local cw_box_open = { 0.5-3/16, -0.5, -0.5,  0.5,      0.5,  0.5     }
--}}}

--{{{ Parts
local parts_for_open = {
    t_1 = {dir = -1, "_b_1", "_t_2", "_b_2"},
    b_1 = {dir =  1, "_t_1", "_b_2", "_t_2"},
    t_2 = {dir = -1, "_b_2", "_t_1", "_b_1"},
    b_2 = {dir =  1, "_t_2", "_b_1", "_t_1"}
}
local parts_for_swap = {
    t_1 = {dir = -1, "_b_1", "_t_1", "_b_1"},
    b_1 = {dir =  1, "_t_1", "_b_1", "_t_1"},
    t_2 = {dir = -1, "_b_2", "_t_2", "_b_2"},
    b_2 = {dir =  1, "_t_2", "_b_2", "_t_2"}
}
--}}}

--}}}

--{{{ Functions

--{{{ can_open_bolted
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
doors.swap_door = function (pos, dir, check_name, replace, replace_dir, meta)
    pos.y = pos.y+dir
    local replace_node = minetest.get_node(pos)

    if replace_node.name ~= check_name then
        return
    end

    minetest.swap_node(pos, {name = replace_dir, param2 = replace_node.param2})

    pos.y = pos.y-dir
    minetest.swap_node(pos, {name = replace, param2 = replace_node.param2})

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
    local parts = parts_for_open[name:sub(-3)]
    name = name:sub(0,-5)
    doors.swap_door(pos, parts.dir,
        name .. parts[1],
        name .. parts[2],
        name .. parts[3])
end
--}}}

    --{{{ after_dig
doors.after_dig = function (pos, oldnode)
    local name, count = string.gsub(oldnode.name, "_t_", "_b_")
    if count == 0 then
        name, count = string.gsub(name, "_b_", "_t_")
    end
        
    if string.find(name, "_t_") then
        pos.y = pos.y + 1
    else
        pos.y = pos.y - 1
    end

    if minetest.get_node(pos).name == name then
        minetest.remove_node(pos)
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

--{{{ rightclick_on_lockable
doors.rightclick_on_lockable = function (pos, node, clicker, wield_item)
    local name = node.name:sub(1,-5)
    local dir, check, pointed_part, second_part = get_swap_parts(name:sub(-3), "swap")

    if wield_item:get_name() == "real_locks:lock" then
        doors.swap_door(pos, dir,
            name .. check,
            name .. "_locked" .. pointed_part,
            name .. "_locked" .. second_part
        )
        wield_item:take_item()
    else
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

--{{{ rightclick_on_boltable
doors.rightclick_on_boltable = function (pos, node, clicker, wield_item)
    local name = node.name:sub(1,-5)
    
    local bolted = "bolted"
    local cw = ""
    if string.find(name, "_cw") then
        bolted = "_bolted_cw"
        cw = "_cw"
        name = name:sub(1,-4)
    end

    local parts = parts_for_swap[node.name:sub(-3)]

    if wield_item:get_name() == "real_locks:bolt" then
        doors.swap_door(pos, parts.dir,
            name .. cw     .. parts[1],
            name .. bolted .. parts[2],
            name .. bolted .. parts[3]
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

--}}}

--{{{ doors:register_door
function doors:register_door(name, def)
	def.groups.not_in_creative_inventory = 1
	
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
				minetest.set_node(pt, {name=name.."_cw_b_1", param2=p2})
				minetest.set_node(pt2, {name=name.."_cw_t_1", param2=p2})
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
	
    --{{{ Node registration

    --{{{ Nodeboxes
    if def.nodeboxes == nil then
        def.nodeboxes = {
            t_1 = box,
            b_1 = box,
            t_2 = box_open,
            b_2 = box_open,

            cw_t_1 = box,
            cw_b_1 = box,
            cw_t_2 = cw_box_open,
            cw_b_2 = cw_box_open,
        }
    end
    --}}}

    if def.rightclick == nil then
        def.rightclick = doors.rightclick_on_not_lockable
    end

    if def.after_dig == nil then
        def.after_dig = doors.after_dig
    end

    for k,part in pairs(nodes) do
	    minetest.register_node(name.."_"..part, {
		    tiles = def.tiles[part],
		    paramtype = "light",
		    paramtype2 = "facedir",
		    drop = name,
		    drawtype = "nodebox",
		    node_box = {
                type = "fixed",
                fixed = def.nodeboxes[part],
            },
		    groups = def.groups,
		    after_dig_node = def.after_dig,
		    on_rightclick = def.rightclick,
	    })
    end

    --}}}
end
--}}}

--{{{ Various doors registration

--{{{ Default tiles table
local tt = {}
local tb = {}
tt = {
    "door_wood_a.png",
    "door_wood_side.png", "door_wood_side_open.png",
    "door_wood_y.png", "door_wood_y_open.png"
}
tb = {
    "door_wood_b.png",
    "door_wood_side.png", "door_wood_side_open.png",
    "door_wood_y.png", "door_wood_y_open.png"
}
local t = {
    t_1 = {
        tt[4], tt[4],
        tt[2], tt[2],
        tt[1], tt[1].."^[transformfx"
    },
    b_1 = {
        tb[4], tb[4],
        tb[2], tb[2],
        tb[1], tb[1].."^[transformfx"
    },
    t_2 = {
        tt[5], tt[5].."^[transformr180",
        tt[1].."^[transformfx", tt[1],
        tt[3], tt[3]
    },
    b_2 = {
        tb[5], tb[5].."^[transformr180",
        tb[1].."^[transformfx", tb[1],
        tb[3], tb[3]
    },

    cw_t_1 = {
        tt[4].."^[transformfx", tt[4].."^[transformfx",
        tt[2].."^[transformfx", tt[2].."^[transformfx",
        tt[1].."^[transformfx", tt[1]
    },
    cw_b_1 = {
        tb[4].."^[transformfx", tb[4].."^[transformfx",
        tb[2].."^[transformfx", tb[2].."^[transformfx",
        tb[1].."^[transformfx", tb[1]
    },
    cw_t_2 = {
        tt[5].."^[transformfx", tt[5].."^[transformfy",
        tt[1].."^[transformfx", tt[1],
        tt[3].."^[transformfx", tt[3].."^[transformfx"
    },
    cw_b_2 = {
        tb[5].."^[transformfx", tb[5].."^[transformfy",
        tb[1].."^[transformfx", tb[1],
        tb[3].."^[transformfx", tb[3].."^[transformfx"
    },
}
--}}}

--{{{ door wood weak
doors:register_door("doors:door_wood_weak", {
    description = "Weak wooden door",
    inventory_image = "door_wood_weak.png",
    groups = {snappy=1,choppy=1,oddly_breakable_by_hand=2,flammable=2,door=1},
    tiles = t,
    rightclick = doors.rightclick_on_boltable
})

-- Bolted version
doors:register_door("doors:door_wood_weak_bolted", {
    description = "Weak wooden door",
    inventory_image = "door_wood_weak.png",
    groups = {snappy=1,choppy=1,oddly_breakable_by_hand=2,flammable=2,door=1},
    tiles = t,
    rightclick = doors.rightclick_on_bolted
})

--}}}

--{{{ door wood
tt = {
    "door_wood_a.png",
    "door_wood_side.png", "door_wood_side_open.png",
    "door_wood_y.png", "door_wood_y_open.png"
}
tb = {
    "door_wood_b.png",
    "door_wood_side.png", "door_wood_side_open.png",
    "door_wood_y.png", "door_wood_y_open.png"
}

doors:register_door("doors:door_wood", {
	description = "Wooden Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
    tiles = t
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

--}}}

--{{{ Various doors registration
--real_locks:register_door("real_locks:door_wood", {
--	description = "Wooden door with lock",
--    infotext = "Locked",
--	inventory_image = "real_locks_door_wood.png",
--	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,door=1,level=1},
--	tiles_bottom = {"real_locks_door_wood_b.png", "real_locks_door_wood_side.png"},
--	tiles_top = {"real_locks_door_wood_a.png", "real_locks_door_wood_side.png"},
--})
--
--real_locks:register_door("real_locks:door_wood_studded", {
--	description = "Wooden door studded with iron, with lock",
--    infotext = "Locked",
--	inventory_image = "real_locks_door_wood_studded.png",
--	groups = {choppy=3,flammable=2,door=1,level=2},
--	tiles_bottom = {"real_locks_door_wood_studded_b.png", "real_locks_door_wood_studded_side.png"},
--	tiles_top = {"real_locks_door_wood_studded_a.png", "real_locks_door_wood_studded_side.png"},
--})
--
--real_locks:register_door("real_locks:door_iron_bars", {
--	description = "Door of iron bars, with lock",
--    infotext = "Locked",
--	inventory_image = "real_locks_door_iron_bars.png",
--	groups = {cracky=1,bendy=2,melty=1,door=1,level=1},
--	tiles_bottom = {"real_locks_door_iron_bars_b.png", "real_locks_door_iron_bars_side.png"},
--	tiles_top = {"real_locks_door_iron_bars_a.png", "real_locks_door_iron_bars_side.png"},
--})
--
--real_locks:register_door("real_locks:door_iron_heavy", {
--	description = "Heavy Metal door with lock",
--    infotext = "Locked",
--	inventory_image = "real_locks_door_iron_heavy.png",
--	groups = {cracky=3,bendy=2,melty=3,door=1,level=3},
--	tiles_bottom = {"real_locks_door_iron_heavy_b.png", "real_locks_door_iron_heavy_side.png"},
--	tiles_top = {"real_locks_door_iron_heavy_a.png", "real_locks_door_iron_heavy_side.png"},
--})
--
--real_locks:register_door("real_locks:door_iron_decorative", {
--	description = "Decorative iron door with lock",
--    infotext = "Locked",
--	inventory_image = "real_locks_door_iron_decorative.png",
--	groups = {cracky=2,bendy=2,melty=2,door=1,level=2},
--	tiles_bottom = {"real_locks_door_iron_decorative_b.png", "real_locks_door_iron_decorative_side.png"},
--	tiles_top = {"real_locks_door_iron_decorative_a.png", "real_locks_door_iron_decorative_side.png"},
--})
--
---- Just an example
--real_locks:register_door("real_locks:door_wood_bolt", {
--	description = "Wooden Door with bolt",
--    infotext = "Bolted",
--	inventory_image = "door_wood.png",
--	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
--	tiles_bottom = {"door_wood_b.png", "door_brown.png"},
--	tiles_top = {"door_wood_a.png", "door_brown.png"},
--    can_open = function (pos, clicker)
--        if string.find(minetest.get_node(pos).name, "_1") then
--            local door_facedir = minetest.get_node(pos).param2
--            local clicker_facedir = minetest.dir_to_facedir(vector.direction(clicker:getpos(),pos))
--            if door_facedir ~= clicker_facedir then return false
--            end
--        end
--        return true
--    end
--})

--}}}
minetest.register_alias("doors:door_wood_a_c", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_a_o", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_b_c", "doors:door_wood_b_1")
minetest.register_alias("doors:door_wood_b_o", "doors:door_wood_b_1")
