-- Signs plugin
-- Based on xyz's code

local sign_width = 200
local poster_width = 320 
local sign_padding = 12

-- avoiding of bug with russian input ====================================== --
function km_process_fields(fields)
    local crutch_table = {
        [string.char(233, 131, 144)]="А", [string.char(235, 131, 144)]="а",
        [string.char(233, 135, 144)]="Б", [string.char(235, 135, 144)]="б",
        [string.char(233, 139, 144)]="В", [string.char(235, 139, 144)]="в",
        [string.char(233, 143, 144)]="Г", [string.char(235, 143, 144)]="г",
        [string.char(233, 147, 144)]="Д", [string.char(235, 147, 144)]="д",
        [string.char(233, 151, 144)]="Е", [string.char(235, 151, 144)]="е",
        [string.char(232, 135, 144)]="Ё", [string.char(233, 135, 145)]="ё",
        [string.char(233, 155, 144)]="Ж", [string.char(235, 155, 144)]="ж",
        [string.char(233, 159, 144)]="З", [string.char(235, 159, 144)]="з",
        [string.char(233, 163, 144)]="И", [string.char(235, 163, 144)]="и",
        [string.char(233, 167, 144)]="Й", [string.char(235, 167, 144)]="й",
        [string.char(233, 171, 144)]="К", [string.char(235, 171, 144)]="к",
        [string.char(233, 175, 144)]="Л", [string.char(235, 175, 144)]="л",
        [string.char(233, 179, 144)]="М", [string.char(235, 179, 144)]="м",
        [string.char(233, 183, 144)]="Н", [string.char(235, 183, 144)]="н",
        [string.char(233, 187, 144)]="О", [string.char(235, 187, 144)]="о",
        [string.char(233, 191, 144)]="П", [string.char(235, 191, 144)]="п",
        [string.char(234, 131, 144)]="Р", [string.char(232, 131, 145)]="р",
        [string.char(234, 135, 144)]="С", [string.char(232, 135, 145)]="с",
        [string.char(234, 139, 144)]="Т", [string.char(232, 139, 145)]="т",
        [string.char(234, 143, 144)]="У", [string.char(232, 143, 145)]="у",
        [string.char(234, 147, 144)]="Ф", [string.char(232, 147, 145)]="ф",
        [string.char(234, 151, 144)]="Х", [string.char(232, 151, 145)]="х",
        [string.char(234, 155, 144)]="Ц", [string.char(232, 155, 145)]="ц",
        [string.char(234, 159, 144)]="Ч", [string.char(232, 159, 145)]="ч",
        [string.char(234, 163, 144)]="Ш", [string.char(232, 163, 145)]="ш",
        [string.char(234, 167, 144)]="Щ", [string.char(232, 167, 145)]="щ",
        [string.char(234, 171, 144)]="Ъ", [string.char(232, 171, 145)]="ъ",
        [string.char(234, 175, 144)]="Ы", [string.char(232, 175, 145)]="ы",
        [string.char(234, 179, 144)]="Ь", [string.char(232, 179, 145)]="ь",
        [string.char(234, 183, 144)]="Э", [string.char(232, 183, 145)]="э",
        [string.char(234, 187, 144)]="Ю", [string.char(232, 187, 145)]="ю",
        [string.char(234, 191, 144)]="Я", [string.char(232, 191, 145)]="я"
    };
    for i = 1, 7 do
        for key, value in pairs(crutch_table) do
            fields["line"..i]= string.gsub(fields["line"..i], key, value)
        end
    end
    return fields
end
-- avoiding of bug with russian input ====================================== --

minetest.register_craft({
    output = "signs:sign",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:wood", "default:wood"},
        {"", "", ""}
    }
})


-- load characters map
local charmap = {}
local charwidth = {}
local max_chars = 16
local chars_file = io.open(minetest.get_modpath(minetest.get_current_modname()).."/characters")
if not chars_file then
    print("[signs] E: character map file not found")
else
    for line in chars_file:lines() do
        char, width, img = string.match(line, "(.+) (%d+) (.+)")
        charmap[char] = img
        charwidth[img] = width
    end
end


local metas = {"line1", "line2", "line3", "line4", "line5", "line6", "line7"}
local poster = {
    {delta = {x = 0, y = 0, z = 0.469}, yaw = 0},
    {delta = {x = 0.469, y = 0, z = 0}, yaw = math.pi / -2},
    {delta = {x = 0, y = 0, z = -0.469}, yaw = math.pi},
    {delta = {x = -0.469, y = 0, z = 0}, yaw = math.pi / 2},
}
local signs = {
    {delta = {x = 0, y = 0, z = 0.399}, yaw = 0},
    {delta = {x = 0.399, y = 0, z = 0}, yaw = math.pi / -2},
    {delta = {x = 0, y = 0, z = -0.399}, yaw = math.pi},
    {delta = {x = -0.399, y = 0, z = 0}, yaw = math.pi / 2},
}

local signs_yard = {
    {delta = {x = 0, y = 0, z = -0.05}, yaw = 0},
    {delta = {x = -0.05, y = 0, z = 0}, yaw = math.pi / -2},
    {delta = {x = 0, y = 0, z = 0.05}, yaw = math.pi},
    {delta = {x = 0.05, y = 0, z = 0}, yaw = math.pi / 2},
}

local sign_groups = {choppy=2, dig_immediate=2}

local construct_sign = function(pos)
    local meta = minetest.env:get_meta(pos)
    meta:set_string("formspec", "size[7,8]"..
        "field[1,0;6,3;line1;;${line1}]"..
        "field[1,1;6,3;line2;;${line2}]"..
        "field[1,2;6,3;line3;;${line3}]"..
        "field[1,3;6,3;line4;;${line4}]"..
        "field[1,4;6,3;line5;;${line5}]"..
        "field[1,5;6,3;line6;;${line6}]"..
        "field[1,6;6,3;line7;;${line7}]")
end

local destruct_sign = function(pos)
    local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
        if v:get_entity_name() == "signs:text" then
            v:remove()
        elseif v:get_entity_name() == "signs:postertext" then
            v:remove()
        end
    end
end

local update_sign = function(pos, fields)
    fields = km_process_fields(fields)  -- HACK: avoiding of bug with russian input
    local meta = minetest.env:get_meta(pos)
    local text = {}
    for _, v in ipairs(metas) do
        table.insert(text, fields[v])
        meta:set_string(v, fields[v])
    end
    local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
        if v:get_entity_name() == "signs:text" then
            v:set_properties({textures={generate_texture(text, sign_width)}})
        elseif v:get_entity_name() == "signs:postertext" then
            v:set_properties({textures={generate_texture(text, poster_width)}})
        end
    end
end

minetest.register_node("signs:poster", {
    description = "Poster",
    inventory_image = "signs_sign.png",
    wield_image = "signs_sign.png",
    stack_max = 64,
    node_placement_prediction = "",
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {-0.35, -0.45, 0.48, 0.35, 0.5, 0.498}},
    selection_box = {type = "fixed", fixed = {-0.35, -0.45, 0.48, 0.35, 0.5, 0.498}},
    tiles = {"poster_front.png", "poster_front.png", "poster_front.png",
             "poster_front.png", "poster_front.png", "poster_front.png"},
    walkable = false,
    groups = sign_groups,

    on_place = function(itemstack, placer, pointed_thing)
        local above = pointed_thing.above
        local under = pointed_thing.under
        local dir = {x = under.x - above.x,
                     y = under.y - above.y,
                     z = under.z - above.z}

        local wdir = minetest.dir_to_wallmounted(dir)

        local placer_pos = placer:getpos()
        if placer_pos then
            dir = {
                x = above.x - placer_pos.x,
                y = above.y - placer_pos.y,
                z = above.z - placer_pos.z
            }
        end

        local fdir = minetest.dir_to_facedir(dir)

        local sign_info
        if wdir == 0 then
            --how would you add sign to ceiling?
            minetest.env:add_item(above, "signs:poster")
            return ItemStack("")
        elseif wdir == 1 then
            minetest.env:add_item(above, "signs:poster")
            return ItemStack("")
        else
            minetest.env:add_node(above, {name = "signs:poster", param2 = fdir})
            sign_info = poster[fdir + 1]
        end

        local text = minetest.env:add_entity({x = above.x + sign_info.delta.x,
                                              y = above.y + sign_info.delta.y,
                                              z = above.z + sign_info.delta.z}, "signs:postertext")
        text:setyaw(sign_info.yaw)

        return ItemStack("")
    end,
    on_construct = function(pos)
        construct_sign(pos)
    end,
    on_destruct = function(pos)
        destruct_sign(pos)
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        update_sign(pos, fields)
    end,
})

minetest.register_node("signs:sign", {
    description = "Sign",
    inventory_image = "signs_sign.png",
    wield_image = "signs_sign.png",
    stack_max = 1,
    node_placement_prediction = "",
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {-0.45, -0.15, 0.4, 0.45, 0.45, 0.498}},
    selection_box = {type = "fixed", fixed = {-0.45, -0.15, 0.4, 0.45, 0.45, 0.498}},
    tiles = {"signs_top.png", "signs_bottom.png", "signs_side.png",
             "signs_side.png", "signs_back.png", "signs_front.png"},
    walkable = false,
    groups = sign_groups,

    on_place = function(itemstack, placer, pointed_thing)
        local above = pointed_thing.above
        local under = pointed_thing.under
        local dir = {x = under.x - above.x,
                     y = under.y - above.y,
                     z = under.z - above.z}

        local wdir = minetest.dir_to_wallmounted(dir)

        local placer_pos = placer:getpos()
        if placer_pos then
            dir = {
                x = above.x - placer_pos.x,
                y = above.y - placer_pos.y,
                z = above.z - placer_pos.z
            }
        end

        local fdir = minetest.dir_to_facedir(dir)

        local sign_info
        if wdir == 0 then
            --how would you add sign to ceiling?
            minetest.env:add_item(above, "signs:sign")
            return ItemStack("")
        elseif wdir == 1 then
            minetest.env:add_node(above, {name = "signs:sign_yard", param2 = fdir})
            sign_info = signs_yard[fdir + 1]
        else
            minetest.env:add_node(above, {name = "signs:sign", param2 = fdir})
            sign_info = signs[fdir + 1]
        end

        local text = minetest.env:add_entity({x = above.x + sign_info.delta.x,
                                              y = above.y + sign_info.delta.y,
                                              z = above.z + sign_info.delta.z}, "signs:text")
        text:setyaw(sign_info.yaw)

        return ItemStack("")
    end,
    on_construct = function(pos)
        construct_sign(pos)
    end,
    on_destruct = function(pos)
        destruct_sign(pos)
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        update_sign(pos, fields)
    end,
})

minetest.register_node("signs:sign_yard", {
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {
        {-0.45, -0.15, -0.049, 0.45, 0.45, 0.049},
        {-0.05, -0.5, -0.049, 0.05, -0.15, 0.049}
    }},
    selection_box = {type = "fixed", fixed = {-0.45, -0.15, -0.049, 0.45, 0.45, 0.049}},
    tiles = {"signs_top.png", "signs_bottom.png", "signs_side.png", "signs_side.png", "signs_back.png", "signs_front.png"},
    walkable = false,
    groups = {choppy=2, dig_immediate=2},
    drop = "signs:sign",

    on_construct = function(pos)
        construct_sign(pos)
    end,
    on_destruct = function(pos)
        destruct_sign(pos)
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        update_sign(pos, fields)
    end,
})

minetest.register_entity("signs:postertext", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
    textures = {},
    on_activate = function(self)
        local meta = minetest.env:get_meta(self.object:getpos())
        local text = {}
        for _, v in ipairs(metas) do
            table.insert(text, meta:get_string(v))
        end
        self.object:set_properties({textures={generate_texture(text, poster_width)}})
    end
})

minetest.register_entity("signs:text", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
    textures = {},
    on_activate = function(self)
        local meta = minetest.env:get_meta(self.object:getpos())
        local text = {}
        for _, v in ipairs(metas) do
            table.insert(text, meta:get_string(v))
        end
        self.object:set_properties({textures={generate_texture(text, sign_width)}})
    end
})


generate_texture = function(lines, width)
    local texture = "[combine:"..width.."x"..width
    local ypos = sign_padding + (width/40)
    for i = 1, #lines do
        texture = texture..generate_line(lines[i], ypos, width)
        ypos = ypos + (width/10)
    end
    return texture
end

generate_line = function(s, ypos, linewidth)
    local i = 1
    local parsed = {}
    local width = 0
    local chars = 0
    while chars < max_chars and i <= #s do
        local file = nil
        if charmap[s:sub(i, i)] ~= nil then
            file = charmap[s:sub(i, i)]
            i = i + 1
        elseif i < #s and charmap[s:sub(i, i + 1)] ~= nil then
            file = charmap[s:sub(i, i + 1)]
            i = i + 2
        else
            print("[signs] W: unknown symbol in '"..s.."' at "..i.." (probably "..s:sub(i, i)..")")
            i = i + 1
        end
        if file ~= nil then
            width = width + charwidth[file] + 1
            table.insert(parsed, file)
            chars = chars + 1
        end
    end
    width = width - 1

    local texture = ""
    local xpos = math.floor((linewidth - 2 * sign_padding - width) / 2 + sign_padding)
    for i = 1, #parsed do
        texture = texture..":"..xpos..","..ypos.."="..parsed[i]..".png"
        xpos = xpos + charwidth[parsed[i]] + 1
    end
    return texture
end
