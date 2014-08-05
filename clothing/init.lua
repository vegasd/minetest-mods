clothing = {}
--{{{ Wear clothing
clothing.update_skin = function(player)
    local weared = player:get_inventory():get_list("wear")
    local skin = default.player_get_animation(player).textures[1]
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
--}}}

--{{{ Save and restore data
minetest.register_on_joinplayer(function(player)
    clothing.update_skin(player)
end)

minetest.register_on_newplayer(function(player)
    -- Add inventory list for clothing
    player:get_inventory():set_list("wear", {})
    player:get_inventory():set_size("wear", 36)
end)
--}}}

--{{{ Cloth
-- Required values is:
-- "wear_image" (this image is adding on player skin)
minetest.register_craftitem("clothing:test", {
    decription = "Test cloth",
    inventory_image = "clothing_test.png",
    wield_image = "clothing_test.png",
    wear_image = "clothing_test.png",
    stack_max = 1,
})
--}}}
