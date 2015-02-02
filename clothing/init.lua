clothing = {}

-- Wear clothing
clothing.update_skin = function(player)
    -- Function gets the player's "wear" inventory list.
    -- It's created by mod "inventory"
    local weared = player:get_inventory():get_list("wear")
    local skin = player:get_player_name() .. ".png"
    for _,itemstack in ipairs(weared) do
        if not itemstack:is_empty() then
            skin = skin .. "^" .. itemstack:get_definition().wear_image
        end
    end
    default.player_set_textures(player, {skin})
    minetest.log("action",
        "update skin for player " ..
        player:get_player_name()
    )
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if (formname == "" or formname:sub(0,9) == "inventory") then
        clothing.update_skin(player)
    end
    print("For debug (from clothing mod) inv. fields:",dump(fields))
end)

minetest.register_on_joinplayer(function(player)
    clothing.update_skin(player)
end)

--{{{ Cloth

-- Names of items (and textures) for autoregistration
clothing.registered = {
    "black_coat",
    "black_glasses",
    "blue_longskirt",
    "blue_waistcoat",
    "brown_hat",
    "brown_hat_wth_badge",
    "hazel_scarf",
    "jabot",
    "leather_boots",
    "leather_dirty_coat",
    "leather_high_boot",
    "leather_long_gloves",
    "linen_shirt",
    "salmon_long_dress",
    "white_apron",
    "white_blouse",
    "white_bonnet",
    "white_greek_dress",
}

for _,name in pairs(clothing.registered) do
    minetest.register_craftitem("clothing:" .. name, {
        description = name:gsub("_", " "):gsub("^.", string.upper),
        inventory_image = "clothing_" ..name.. "_inv.png",
        wield_image = "clothing_" ..name.. "_inv.png",
        wear_image = "clothing_" ..name.. ".png",
        stack_max = 1,
    })
end

-- Special case
minetest.register_craftitem("clothing:test1", {
    description = "Test cloth 1",
    inventory_image = "clothing_test.png",
    wield_image = "clothing_test.png",
    wear_image = "clothing_test.png",
    stack_max = 1,
})
minetest.register_craftitem("clothing:test2", {
    description = "Test cloth 2",
    inventory_image = "clothing_test2.png",
    wield_image = "clothing_test2.png",
    wear_image = "clothing_test2.png",
    stack_max = 1,
})
minetest.register_craftitem("clothing:test3", {
    description = "Test cloth 3",
    inventory_image = "clothing_test3.png",
    wield_image = "clothing_test3.png",
    wear_image = "clothing_test3.png",
    stack_max = 1,
})
--}}}
