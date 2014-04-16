real_locks = {}

--{{{ Default can_open() for locked object
real_locks.can_open_locked = function (pos, wield)
    if wield:get_name() == "real_locks:key" then 
		local lock_pass = minetest.get_meta(pos):get_string("lock_pass")
		local key_pass = wield:get_metadata()

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

minetest.register_craftitem("real_locks:bolt", {
    description = "Bolt",
    groups = {},
    inventory_image = "real_locks_bolt.png",
    wield_image = "real_locks_bolt.png",
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
