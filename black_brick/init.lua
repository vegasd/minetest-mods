minetest.register_node("black_brick:brick",{
    description = "Black Brick",
    tiles = {"black_brick.png"},
	groups = {cracky=3, stone=1},
    drop = "black_brick:brick",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("black_brick:fence", {
	description = "Black Fence",
	drawtype = "fencelike",
	tiles = {"black_brick.png"},
	--inventory_image = "default_fence.png",
	--wield_image = "default_fence.png",
	paramtype = "light",
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_stone_defaults(),
})

stairs.register_stair_and_slab("black_brick", "black_brick:brick",
    {cracky=3},
    {"black_brick.png"},
    "Black Brick Stair",
    "Black Brick Slab",
    default.node_sound_stone_defaults()
)
