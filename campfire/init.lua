-- fire definition (distance from entity to center(x, y and z) and angle of rotation)
local fire_struct ={
    [1]={0, -0.2, 0.29, 0},
    [2]={0.29, -0.2, 0, math.pi/2},
    [3]={-0.29, -0.2, 0, 3*math.pi/2},
    [4]={0, -0.2, -0.29, math.pi},
    [5]={0, 0, 0, -math.pi/4},
    [6]={0, 0, 0, math.pi/4}
}
--

minetest.register_node("campfire:fireplace", {
    description = "Fireplace",
    stack_max = 1,
    tiles = { "default_cobble.png"},
    paramtype2 = "facedir",
    drawtype = "nodebox",
    paramtype = "light",

    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.3, -0.3, -0.3, 0.3},
            {-0.3, -0.5, 0.5, 0.3, -0.3, 0.3},
            {0.3, -0.5, 0.3, 0.5, -0.3, -0.3},
            {-0.3, -0.5, -0.3, 0.3, -0.3, -0.5},
            },
        },

    groups = {dig_immediate=2},

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        for _, v in ipairs(fire_struct) do
            minetest.add_entity({x=pos.x+v[1],y=pos.y+v[2],z=pos.z+v[3]}, "campfire:fire"):setyaw(v[4])
        end
	minetest.swap_node(pos, {name="campfire:fireplace_fire"})
    end,

})

minetest.register_node("campfire:fireplace_fire", {
    tiles = { "default_cobble.png"},
    paramtype2 = "facedir",
    drawtype = "nodebox",
    paramtype = "light",
    drop = "campfire:fireplace",

    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.3, -0.3, -0.3, 0.3},
            {-0.3, -0.5, 0.5, 0.3, -0.3, 0.3},
            {0.3, -0.5, 0.3, 0.5, -0.3, -0.3},
            {-0.3, -0.5, -0.3, 0.3, -0.3, -0.5},
            },
        },

    groups = {dig_immediate=2, hot=1, not_in_creative_inventory=1},
    light_source = 50,
    damage_per_second = 4,

    on_destruct = function(pos)
        local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
        for _, v in ipairs(objects) do
            if v:get_entity_name() == "campfire:fire" then
                v:remove()
            end
        end
    end
})

local frame_max = 8 -- amount of frames in fire animation
local frame_speed = 0.2 -- animation speed: seconds on frame

local frame = 1
local frame_time = 0

-- Global function, which control frame changing
minetest.register_globalstep(
    function(dtime)
        if frame_time > frame_speed then
            if frame < frame_max then
                frame=frame+1
            else
                frame=1
            end
            frame_time=0
        end
        frame_time = frame_time + dtime
    end
)

minetest.register_entity("campfire:fire", {
    collisionbox = {0,0,0,0,0,0},
    visual = "upright_sprite",
    visual_size = {x=0.6, y=0.8},
    textures =     {"fire_basic_flame.png"},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = true,

-- Updating fire texture for animation. DONT TOUCH, MAZAFUCKER! I know that it can be crutch. I'll sleep and fix it by myself.
    on_step = function(self, dtime)
            self.object:set_properties({textures ={"campfire_fire_"..frame ..".png"}})
    end
--
})
