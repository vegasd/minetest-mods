real_locks = {}

--{{{ Defaul can_open() for locked object
real_locks.can_open_locked = function (pos, wield)
    if wield:get_name() == "real_locks:key" then 
		local lock_pass = minetest.get_meta(pos):get_string("lock_pass")
		local key_pass = wield_item:get_metadata()

		return lock_pass == key_pass
    else
        return false
    end
end
--}}}

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

--{{{ Various doors registration
--real_locks:register_door("real_locks:door_wood_weak", {
----	description = "Weak wooden door with lock",
--    infotext = "Locked",
--	inventory_image = "real_locks_door_wood_weak.png",
--	groups = {snappy=1,choppy=1,oddly_breakable_by_hand=2,flammable=2,door=1},
--	tiles_bottom = {"real_locks_door_wood_weak_b.png", "real_locks_door_wood_weak_side.png"},
--	tiles_top = {"real_locks_door_wood_weak_a.png", "real_locks_door_wood_weak_side.png"},
--})
--
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
