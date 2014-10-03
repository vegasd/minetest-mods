minetest.register_node("gallows:knot", {
    description = "Gallows rope",
    drawtype = "airlike",
    paramtype = "light",
    inventory_image = "gallows_knot.png",
    wield_image = "gallows_knot.png",
    
    selection_box = {
        type = "fixed",
        fixed = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1}
    },
    
    groups = {cracky=3 },
    
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local rope = minetest.add_entity(pos, "gallows:knot_entity");
        rope:setyaw( placer:get_look_yaw() + math.pi/2 );
    end,
    
    on_destruct = function(pos)
        local all_objects = minetest.get_objects_inside_radius(pos, 0.9);
        for _,obj in ipairs(all_objects) do
            tmp = obj:get_luaentity();
            if (tmp.name == "gallows:knot_entity") then 
                obj:remove(); 
            end
        end
    end
})


minetest.register_entity("gallows:knot_entity",{
    hp_max = 1,
    physical = false,
    visual = "upright_sprite",
    collisionbox = {0,0,0,0,0,0},
    visual_size = {x=1, y=1},
    textures = {"gallows_knot.png"},
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
})

--[[
minetest.register_entity("gallows:hangman_entity",{
    hp_max = 1,
    physical = false,
    visual = "mesh",
    mesh = "character.x",
    collisionbox = {0,0,0,0,0,0},
    visual_size = {x=1, y=1},
    textures = {"character.png"},
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
})
]]--
