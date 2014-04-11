clothing = {}

--{{{ Wear clothing (on_place)
local function clothingPutOn(item, player)
    local name = player:get_player_name()
    local wear_image = item:get_definition().wear_image
    local weared = clothing[name]

    table.insert(weared, wear_image)

    local skin = ""
    for _,clothing in ipairs(weared) do
        if skin ~= "" then
            skin = skin .. "^" .. clothing
        else
            skin = clothing
        end
    end

    default.player_set_textures(player, {skin})
    minetest.log("action", name .. " puts on a " .. item:get_name())

    item:take_item()
    return item
end
--}}}

minetest.register_on_newplayer(function(player)
    --TODO: default.player_get_animations().textures (returns nil, becouse
    -- using default textures). Needs skin system.
    local skin = default.registered_player_models["character.x"].textures
    clothing[player:get_player_name()] = skin
end)

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

    on_place = clothingPutOn
})
