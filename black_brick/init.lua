minetest.register_node("black_brick:brick",{
    description = "Black Brick",
    tiles = {"black_brick.png"},
	groups = {cracky=3, stone=1},
    drop = "black_brick:brick",
	sounds = default.node_sound_stone_defaults(),
})
