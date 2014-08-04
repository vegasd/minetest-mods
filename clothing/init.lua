--{{{ Wear clothing (on_place)
local function put_on(item, player)
    local wname = item:get_name()
    item = player:get_inventory():add_item("wear", item)
    minetest.log("action",
        player:get_player_name() ..
        " puts on a " ..
        wname
    )
    
    default.player_set_textures(player, {generate_skin(player)})
    minetest.log("action",
        "update skin for player " ..
        player:get_player_name()
    )

    return item
end

function generate_skin(player)
    local weared = player:get_inventory():get_list("wear")
    local skin = default.player_get_animation(player).textures[1]
    for _,itemstack in ipairs(weared) do
        if not itemstack:is_empty() then
            skin = skin .. "^" .. itemstack:get_definition().wear_image
        end
    end
    return skin
end
--}}}

--{{{ Save data
minetest.register_on_joinplayer(function(player)
    default.player_set_textures(player, {generate_skin(player)})
end)

--minetest.register_on_player_receive_fields(function(player, formname, fields)
--    print("DEBUG:", player, dump(formname), dump(fields))
--end)

minetest.register_on_newplayer(function(player)
    -- Add inventory list for clothing
    player:get_inventory():set_list("wear", {})
    player:get_inventory():set_size("wear", 36)
end)
--}}}

--{{{ Cloth
-- Required values is:
-- "wear_image" (this image is adding on player skin)
-- "on_place" (this is obvious)
minetest.register_craftitem("clothing:test", {
    decription = "Test cloth",
    inventory_image = "clothing_test.png",
    wield_image = "clothing_test.png",
    wear_image = "clothing_test.png",
    stack_max = 1,

    on_place = put_on
})
--}}}
