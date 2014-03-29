minetest.register_craftitem("clothing:test", {
    decription = "Test cloth",
    inventory_image = "clothing_test.png",
    wield_image = "clothing_test.png",
    stack_max = 1,

    on_place = function(itemstack, placer, pointed_thing)
        local skin = default.registered_player_models["character.x"].textures
        skin[1] = skin[1] .. "^" .. "clothing_test.png"
        default.player_set_textures(placer, skin)
    end
})
