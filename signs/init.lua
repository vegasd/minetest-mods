-- Font: 04.jp.org

-- avoiding of bug with russian input =========================================================================================================
local crutch_table = {
["233131144"]="А",
["235131144"]="а",

["233135144"]="Б",
["235135144"]="б",

["233139144"]="В",
["235139144"]="в",

["233143144"]="Г",
["235143144"]="г",

["233147144"]="Д",
["235147144"]="д",

["233151144"]="Е",
["235151144"]="е",

["232135144"]="Ё",
["233135145"]="ё",

["233155144"]="Ж",
["235155144"]="ж",

["233159144"]="З",
["235159144"]="з",

["233163144"]="И",
["235163144"]="и",

["233167144"]="Й",
["235167144"]="й",

["233171144"]="К",
["235171144"]="к",

["233175144"]="Л",
["235175144"]="л",

["233179144"]="М",
["235179144"]="м",

["233183144"]="Н",
["235183144"]="н",

["233187144"]="О",
["235187144"]="о",

["233191144"]="П",
["235191144"]="п",

["234131144"]="Р",
["232131145"]="р",

["234135144"]="С",
["232135145"]="с",

["234139144"]="Т",
["232139145"]="т",

["234143144"]="У",
["232143145"]="у",

["234147144"]="Ф",
["232147145"]="ф",

["234151144"]="Х",
["232151145"]="х",

["234155144"]="Ц",
["232155145"]="ц",

["234159144"]="Ч",
["232159145"]="ч",

["234163144"]="Ш",
["232163145"]="ш",

["234167144"]="Щ",
["232167145"]="щ",

["234171144"]="Ъ",
["232171145"]="ъ",

["234175144"]="Ы",
["232175145"]="ы",

["234179144"]="Ь",
["232179145"]="ь",

["234183144"]="Э",
["232183145"]="э",

["234187144"]="Ю",
["232187145"]="ю",

["234191144"]="Я",
["232191145"]="я"
};



function tobytes(str)
 i=1
 byte={}
 while i<=#str do
  table.insert(byte, string.byte(string.sub(str, i, i)))
  i=i+1
 end
 return byte;
end

function string.km_rus_crutch_regen(str)
 byte=tobytes(str)
 text=""
 if byte[1]~=nil then
 i=1
 repeat
  if byte[i]>128 then
   if byte[i+2]~=nil and byte[i+1]~=nil and byte[i] then
    tmp = byte[i]..byte[i+1]..byte[i+2]
   else
    tmp = "0"
   end

   if crutch_table[tmp]~=nil then
    char = crutch_table[tmp]
    i=i+3
   else
    char = string.sub(str, i, i+1)
    i=i+2
   end
  else
   char=string.sub(str, i, i)
   i=i+1
  end
  text=text..char
 until i>#byte 
 end
 return text
end
-- ============================================================================================================================================

minetest.register_craft({
    output = "signs:sign",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:wood", "default:wood"},
        {"", "", ""}
    }
})


-- load characters map
local chars_file = io.open(minetest.get_modpath(minetest.get_current_modname()).."/characters", "r")
local charmap = {}
local charwidth = {}
local max_chars = 16
if not chars_file then
    print("[signs] E: character map file not found")
else
    while true do
        local char = chars_file:read("*l")
        if char == nil then
            break
        end
        local img = chars_file:read("*l")
        local width = chars_file:read("*n")
        chars_file:read("*l")
        charmap[char] = img
        charwidth[img] = width
    end
end

local metas = {"line1", "line2", "line3", "line4", "line5", "line6", "line7"}
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
        end
    end
end

local update_sign = function(pos, fields)
    local meta = minetest.env:get_meta(pos)
    local text = {}
    for _, v in ipairs(metas) do
        table.insert(text, fields[v])
        meta:set_string(v, fields[v])
    end
    local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
        if v:get_entity_name() == "signs:text" then
            v:set_properties({textures={generate_texture(text)}})
        end
    end
end

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
    tiles = {"signs_top.png", "signs_bottom.png", "signs_side.png", "signs_side.png", "signs_back.png", "signs_front.png"},
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
-- avoiding of bug with russian input =========================================================================================================
     line_cycle=1; --cycle parametr
     while line_cycle<8 do
       fields["line"..line_cycle]= string.km_rus_crutch_regen(fields["line"..line_cycle])
       line_cycle=line_cycle+1
     end
--end==========================================================================================================================================
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

-- avoiding of bug with russian input =========================================================================================================
     line_cycle=1; --cycle parametr
     while line_cycle<8 do
       fields["line"..line_cycle]= string.km_rus_crutch_regen(fields["line"..line_cycle])
       line_cycle=line_cycle+1
     end
--end==========================================================================================================================================

     update_sign(pos, fields)
    end,
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
        self.object:set_properties({textures={generate_texture(text)}})
    end
})

local sign_width = 110
local sign_padding = 8

generate_texture = function(lines)
    local texture = "[combine:"..sign_width.."x"..sign_width
    local ypos = 12
    for i = 1, #lines do
        texture = texture..generate_line(lines[i], ypos)
        ypos = ypos + 12 
    end
    return texture
end

generate_line = function(s, ypos)
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
    local xpos = math.floor((sign_width - 2 * sign_padding - width) / 2 + sign_padding)
    for i = 1, #parsed do
        texture = texture..":"..xpos..","..ypos.."="..parsed[i]..".png"
        xpos = xpos + charwidth[parsed[i]] + 1
    end
    return texture
end
