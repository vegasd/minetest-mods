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
        metadata:set_string(meta[1], meta[2])
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
doors.add_lock = function (pos, node, wield_item, lock_type, meta)
    local name = node.name:sub(1,-5)
    local p2 = node.param2
    local pos2 = {y = pos.y}

    local locked = "_" .. lock_type
    local lock_o = "_" .. lock_type .. "_cw"
    local cw = ""
    local opposite = "_cw"
    if string.find(name, "_cw") then
        -- Swap values
        locked, lock_o = lock_o, locked
        cw, opposite = opposite, cw

        name = name:sub(1,-4)

        if p2 == 0 then
            pos2.x = pos.x-1
            pos2.z = pos.z
        elseif p2 == 1 then
            pos2.z = pos.z+1
            pos2.x = pos.x
        elseif p2 == 2 then
            pos2.x = pos.x+1
            pos2.z = pos.z
        elseif p2 == 3 then
            pos2.z = pos.z-1
            pos2.x = pos.x
        end
    else
        if p2 == 0 then
            pos2.x = pos.x+1
            pos2.z = pos.z
        elseif p2 == 1 then
            pos2.z = pos.z-1
            pos2.x = pos.x
        elseif p2 == 2 then
            pos2.x = pos.x-1
            pos2.z = pos.z
        elseif p2 == 3 then
            pos2.z = pos.z+1
            pos2.x = pos.x
        end
    end

    local parts = parts_for_swap[node.name:sub(-3)]
    doors.swap_door(pos, parts.dir,
        name .. cw     .. parts[1],
        name .. locked .. parts[2],
        name .. locked .. parts[3],
        meta
    )

    parts = parts_for_swap[minetest.get_node(pos2).name:sub(-3)]
    if parts ~= nil then
        doors.swap_door(pos2, parts.dir,
            name .. opposite .. parts[1],
            name .. lock_o   .. parts[2],
            name .. lock_o   .. parts[3],
            meta
        )
    end

    wield_item:take_item()
end
--}}}

--{{{ rightclock_on_bolted
doors.rightclick_on_bolted = function(pos, node, clicker)
    if doors.can_open_bolted(pos, node, clicker) then
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

    if def.on_rightclick == nil then
        def.on_rightclick = doors.rightclick_on_not_lockable
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
		    on_rightclick = def.on_rightclick,
            on_construct = def.on_construct,
	    })
    end

    --}}}
end
--}}}

--{{{ Various doors registration

--{{{ Default tiles table
local function setTiles(tiles)
    local t = {
        t_1 = {
            tiles[5], tiles[5],
            tiles[3], tiles[3],
            tiles[1], tiles[1].."^[transformfx"
        },
        b_1 = {
            tiles[5], tiles[5],
            tiles[3], tiles[3],
            tiles[2], tiles[2].."^[transformfx"
        },
        t_2 = {
            tiles[6], tiles[6].."^[transformr180",
            tiles[1].."^[transformfx", tiles[1],
            tiles[4], tiles[4]
        },
        b_2 = {
            tiles[6], tiles[6].."^[transformr180",
            tiles[2].."^[transformfx", tiles[2],
            tiles[4], tiles[4]
        },
    
        cw_t_1 = {
            tiles[5].."^[transformfx", tiles[5].."^[transformfx",
            tiles[3].."^[transformfx", tiles[3].."^[transformfx",
            tiles[1].."^[transformfx", tiles[1]
        },
        cw_b_1 = {
            tiles[5].."^[transformfx", tiles[5].."^[transformfx",
            tiles[3].."^[transformfx", tiles[3].."^[transformfx",
            tiles[2].."^[transformfx", tiles[2]
        },
        cw_t_2 = {
            tiles[6].."^[transformfx", tiles[6].."^[transformfy",
            tiles[1].."^[transformfx", tiles[1],
            tiles[4].."^[transformfx", tiles[4].."^[transformfx"
        },
        cw_b_2 = {
            tiles[6].."^[transformfx", tiles[6].."^[transformfy",
            tiles[2].."^[transformfx", tiles[2],
            tiles[4].."^[transformfx", tiles[4].."^[transformfx"
        },
    }
    return t
end
--}}}

local t

--{{{ door wood weak
t = setTiles({
    "door_wood_weak_a.png", "door_wood_weak_b.png",
    "door_wood_weak_side.png", "door_wood_weak_side_open.png",
    "door_wood_weak_y.png", "door_wood_weak_y_open.png"
})

doors:register_door("doors:door_wood_weak", {
    description = "Weak wooden door",
    inventory_image = "door_wood_weak.png",
    groups = {snappy=1,choppy=1,oddly_breakable_by_hand=2,flammable=2,door=1},
    tiles = t,
    on_rightclick = function (pos, node, clicker, wield_item)
        if wield_item:get_name() == "real_locks:bolt" then
            doors.add_lock(pos, node, wield_item, "bolt")
        else
            doors.open_door(pos, node.name)
        end
    end
})

-- Bolted version
doors:register_door("doors:door_wood_weak_bolt", {
    description = "Weak wooden door",
    inventory_image = "door_wood_weak.png",
    groups = {snappy=1,choppy=1,oddly_breakable_by_hand=2,flammable=2,door=1},
    tiles = t,
    on_rightclick = doors.rightclick_on_bolted,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Bolted")
    end
})

--}}}

--{{{ door wood
t = setTiles({
    "door_wood_a.png","door_wood_b.png",
    "door_wood_side.png", "door_wood_side_open.png",
    "door_wood_y.png", "door_wood_y_open.png"
})

doors:register_door("doors:door_wood", {
	description = "Wooden Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,door=1,level=1},
    tiles = t,
    on_rightclick = function (pos, node, clicker, wield_item)
        if wield_item:get_name() == "real_locks:lock" then
            doors.add_lock(
                pos, node, wield_item, "lock",
                {"lock_pass", wield_item:get_metadata()}
            )
        elseif wield_item:get_name() == "real_locks:bolt" then
            doors.add_lock(pos, node, wield_item, "bolt")
        else
            doors.open_door(pos, node.name)
        end
    end
})

-- Bolted version
doors:register_door("doors:door_wood_bolt", {
	description = "Wooden Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,door=1,level=1},
    tiles = t,
    on_rightclick = doors.rightclick_on_bolted,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Bolted")
    end
})

-- Locked version
doors:register_door("doors:door_wood_lock", {
	description = "Wooden Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,door=1,level=1},
    tiles = t,
    on_rightclick = doors.rightclick_on_locked,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Locked")
    end
})

-- Craft
minetest.register_craft({
	output = "doors:door_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})
--}}}

--{{{ door wood studded
t = setTiles({
    "door_wood_studded_a.png","door_wood_studded_b.png",
    "door_wood_studded_side.png", "door_wood_studded_side_open.png",
    "door_wood_studded_y.png", "door_wood_studded_y_open.png"
})

doors:register_door("doors:door_wood_studded", {
	description = "Wooden door, studded with iron",
	inventory_image = "door_wood_studded.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,door=1,level=1},
    tiles = t,
    on_rightclick = function (pos, node, clicker, wield_item)
        if wield_item:get_name() == "real_locks:lock" then
            doors.add_lock(
                pos, node, wield_item, "lock",
                {"lock_pass", wield_item:get_metadata()}
            )
        elseif wield_item:get_name() == "real_locks:bolt" then
            doors.add_lock(pos, node, wield_item, "bolt")
        else
            doors.open_door(pos, node.name)
        end
    end
})

-- Bolted version
doors:register_door("doors:door_wood_studded_bolt", {
	description = "Wooden door, studded with iron, with bolt",
	inventory_image = "door_wood_studded.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,door=1,level=1},
    tiles = t,
    on_rightclick = doors.rightclick_on_bolted,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Bolted")
    end
})

-- Locked version
doors:register_door("doors:door_wood_studded_lock", {
	description = "Wooden door, studded with iron, with lock",
	inventory_image = "door_wood_studded.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,door=1,level=1},
    tiles = t,
    on_rightclick = doors.rightclick_on_locked,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Locked")
    end
})

-- Craft
minetest.register_craft({
	output = "doors:door_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})
--}}}

--{{{ door iron bars
t = setTiles({
    "door_iron_bars_a.png","door_iron_bars_b.png",
    "door_iron_bars_side.png", "door_iron_bars_side_open.png",
    "door_iron_bars_y.png", "door_iron_bars_y_open.png"
})

doors:register_door("doors:door_iron_bars", {
	description = "Door of iron bars",
	inventory_image = "door_iron_bars.png",
    groups = {cracky=1,bendy=2,melty=1,door=1,level=1},
    tiles = t,
    on_rightclick = function (pos, node, clicker, wield_item)
        if wield_item:get_name() == "real_locks:lock" then
            doors.add_lock(
                pos, node, wield_item, "lock",
                {"lock_pass", wield_item:get_metadata()}
            )
        else
            doors.open_door(pos, node.name)
        end
    end
})

-- Locked version
doors:register_door("doors:door_iron_bars_lock", {
	description = "Door of iron bars, with lock",
	inventory_image = "door_iron_bars.png",
    groups = {cracky=1,bendy=2,melty=1,door=1,level=1},
    tiles = t,
    on_rightclick = doors.rightclick_on_locked,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Locked")
    end
})

-- Craft
minetest.register_craft({
	output = "doors:door_iron_bars",
	recipe = {
		{"default:steel_ingot",""},
		{"default:steel_ingot",""},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})
--}}}

--{{{ door iron heavy
t = setTiles({
    "door_iron_heavy_a.png","door_iron_heavy_b.png",
    "door_iron_heavy_side.png", "door_iron_heavy_side_open.png",
    "door_iron_heavy_y.png", "door_iron_heavy_y_open.png"
})

doors:register_door("doors:door_iron_heavy", {
	description = "Heavy Metal door",
	inventory_image = "door_iron_heavy.png",
    groups = {cracky=3,bendy=2,melty=3,door=1,level=3},
    tiles = t,
    on_rightclick = function (pos, node, clicker, wield_item)
        if wield_item:get_name() == "real_locks:lock" then
            doors.add_lock(
                pos, node, wield_item, "lock",
                {"lock_pass", wield_item:get_metadata()}
            )
        elseif wield_item:get_name() == "real_locks:bolt" then
            doors.add_lock(pos, node, wield_item, "bolt")
        else
            doors.open_door(pos, node.name)
        end
    end
})

-- Bolted version
doors:register_door("doors:door_iron_heavy_bolt", {
	description = "Heavy Metal door, with bolt",
	inventory_image = "door_iron_heavy.png",
    groups = {cracky=3,bendy=2,melty=3,door=1,level=3},
    tiles = t,
    on_rightclick = doors.rightclick_on_bolted,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Bolted")
    end
})

-- Locked version
doors:register_door("doors:door_iron_heavy_lock", {
	description = "Heavy Metal door, with lock",
	inventory_image = "door_iron_heavy.png",
    groups = {cracky=3,bendy=2,melty=3,door=1,level=3},
    tiles = t,
    on_rightclick = doors.rightclick_on_locked,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Locked")
    end
})

-- Craft
minetest.register_craft({
	output = "doors:door_iron_heavy",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})
--}}}

--{{{ door iron decorative
t = setTiles({
    "door_iron_decorative_a.png","door_iron_decorative_b.png",
    "door_iron_decorative_side.png", "door_iron_decorative_side_open.png",
    "door_iron_decorative_y.png", "door_iron_decorative_y_open.png"
})

doors:register_door("doors:door_iron_decorative", {
	description = "Decorative iron door",
	inventory_image = "door_iron_decorative.png",
    groups = {cracky=2,bendy=2,melty=2,door=1,level=2},
    tiles = t,
    on_rightclick = function (pos, node, clicker, wield_item)
        if wield_item:get_name() == "real_locks:lock" then
            doors.add_lock(
                pos, node, wield_item, "lock",
                {"lock_pass", wield_item:get_metadata()}
            )
        else
            doors.open_door(pos, node.name)
        end
    end
})

-- Locked version
doors:register_door("doors:door_iron_decorative_lock", {
	description = "Decorative iron door, with lock",
	inventory_image = "door_iron_decorative.png",
    groups = {cracky=2,bendy=2,melty=2,door=1,level=2},
    tiles = t,
    on_rightclick = doors.rightclick_on_locked,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Locked")
    end
})

-- Craft
minetest.register_craft({
	output = "doors:door_iron_decorative",
	recipe = {
		{"", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})
--}}}
--}}}

minetest.register_alias("doors:door_wood_a_c", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_a_o", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_b_c", "doors:door_wood_b_1")
minetest.register_alias("doors:door_wood_b_o", "doors:door_wood_b_1")
