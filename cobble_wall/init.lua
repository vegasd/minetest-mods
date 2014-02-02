local function rshift(x, by)
  return math.floor(x / 2 ^ by)
end

local directions = {
    {x = 1, y = 0, z = 0},
    {x = 0, y = 0, z = 1},
    {x = -1, y = 0, z = 0},
    {x = 0, y = 0, z = -1},
    {x = 0, y = -1, z = 0},
}

local function update_wall(pos)
    if minetest.env:get_node(pos).name:find("cobble_wall:wall") == nil then
        return
    end
    local sum = 0
    for i = 1, 4 do
        local node = minetest.env:get_node({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
        if minetest.registered_nodes[node.name].walkable then
            sum = sum + 2 ^ (i - 1)
        end
    end

    local node = minetest.env:get_node({x = pos.x, y = pos.y+1, z = pos.z})
    if sum == 5 or sum == 10 then
        if minetest.registered_nodes[node.name].walkable then
            sum = sum + 11
        end
    end

    --if sum == 0 then
        --sum = 15
    --end
    minetest.env:add_node(pos, {name = "cobble_wall:wall_"..sum})
end

local function update_nearby(pos)
    for i = 1,5 do
        update_wall({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
    end
end

local half_blocks = {
    {4/16, -0.5, -3/16, 0.5, 5/16, 3/16},
    {-3/16, -0.5, 4/16, 3/16, 5/16, 0.5},
    {-0.5, -0.5, -3/16, -4/16, 5/16, 3/16},
    {-3/16, -0.5, -0.5, 3/16, 5/16, -4/16}
}

local pillar = {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16}

local full_blocks = {
    {-0.5, -0.5, -3/16, 0.5, 5/16, 3/16},
    {-3/16, -0.5, -0.5, 3/16, 5/16, 0.5}
}

for i = 0, 15 do
    local need = {}
    local need_pillar = false
    for j = 1, 4 do
        if rshift(i, j - 1) % 2 == 1 then
            need[j] = true
        end
    end

    local take = {}
    if need[1] == true and need[3] == true then
        need[1] = nil
        need[3] = nil
        table.insert(take, full_blocks[1])
    end
    if need[2] == true and need[4] == true then
        need[2] = nil
        need[4] = nil
        table.insert(take, full_blocks[2])
    end
    for k in pairs(need) do
        table.insert(take, half_blocks[k])
        need_pillar = true
    end
    if i == 15 or i == 0 then need_pillar = true end
    if need_pillar then table.insert(take, pillar) end

    minetest.register_node("cobble_wall:wall_"..i, {
        drawtype = "nodebox",
        tile_images = {"default_cobble.png"},
        paramtype = "light",
        groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
        drop = "cobble_wall:wall",
        node_box = {
            type = "fixed",
            fixed = take
        },
    })
end

minetest.register_node("cobble_wall:wall_0", {
    drawtype = "nodebox",
    tile_images = {"default_cobble.png"},
    paramtype = "light",
    groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
    drop = "cobble_wall:wall",
    node_box = {
        type = "fixed",
        fixed = pillar
    },
})

minetest.register_node("cobble_wall:wall_16", {
    drawtype = "nodebox",
    tile_images = {"default_cobble.png"},
    paramtype = "light",
    groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
    drop = "cobble_wall:wall",
    node_box = {
        type = "fixed",
        fixed = {pillar, full_blocks[1]}
    },
})

minetest.register_node("cobble_wall:wall_21", {
    drawtype = "nodebox",
    tile_images = {"default_cobble.png"},
    paramtype = "light",
    groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
    drop = "cobble_wall:wall",
    node_box = {
        type = "fixed",
        fixed = {pillar, full_blocks[2]}
    },
})

minetest.register_node("cobble_wall:wall", {
    description = "Cobblestone Wall",
    tile_images = {"default_cobble.png"},
    stack_max = 64,

    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = pillar
    },

    on_construct = update_wall
})

minetest.register_on_placenode(update_nearby)
minetest.register_on_dignode(update_nearby)

minetest.register_craft({
	output = 'cobble_wall:wall 16',
	recipe = {
		{'default:cobble', 'default:cobble', 'default:cobble'},
        {'default:cobble', 'default:cobble', 'default:cobble'}
	}
})
