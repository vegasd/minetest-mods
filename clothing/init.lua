clothing = {}

--{{{ Wear clothing (on_place)
local function put_on(item, player)
    local name = player:get_player_name()
    local wear_image = item:get_definition().wear_image
    local weared = clothing[name] or {}

    table.insert(weared, wear_image)

    local skin = default.player_get_animation(player).textures[1]
    for _,clothing in ipairs(weared) do
        skin = skin .. "^" .. clothing
    end

    default.player_set_textures(player, {skin})
    minetest.log("action", name .. " puts on a " .. item:get_name())

    item:take_item()
    return item
end
--}}}

--{{{ Save data
minetest.register_on_shutdown(function()
end)

minetest.register_globalstep(function(dtime)
end)
--}}}

minetest.register_craftitem("clothing:test", {
    decription = "Test cloth",
    inventory_image = "clothing_test.png",
    wield_image = "clothing_test.png",
    wear_image = "clothing_test.png",
    stack_max = 1,

    on_place = put_on
})
