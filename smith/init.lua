minetest.register_chatcommand("csmith", {
    func = function ()
        new_node = {
            description = "Test object",
            tiles = {"default_wood.png"},
        	groups = {cracky=3, stone=1},
        	sounds = default.node_sound_stone_defaults(),
        }
        minetest.register_node(":test", new_node)
    end,
})
