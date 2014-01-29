minetest.register_node("black_brick:brick",{
    description = "Black Brick",
    tiles = {"black_brick.png"},
	groups = {cracky=3, stone=1},
    drop = "black_brick:brick",
	sounds = default.node_sound_stone_defaults(),
})

stairs.register_stair_and_slab("black_brick", "black_brick:brick",
    {cracky=3},
    {"black_brick.png"},
    "Black Brick Stair",
    "Black Brick Slab",
    default.node_sound_stone_defaults()
)
