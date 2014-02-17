real_locks = {}
real_locks.meta = {}

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

minetest.register_craft({
    type = "shapeless",
    output = "real_locks:key",
    recipe = {
        "default:steel_ingot",
        "default:steel_ingot",
    },
})
