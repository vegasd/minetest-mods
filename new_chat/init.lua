minetest.register_on_chat_message(function(name,message)
    minetest.get_player_by_name(name):hud_add({
        hud_elem_type = "text",
        text = message,
        position = {x=0.05,y=0.9},
        name = "chat",
        scale = {x=500, y=50},
        number = 0xFFFFFF,
        item = 0,
        direction = 0,
        alignment = {x=0, y=0},
        offset = {x=0, y=0}
    })
    
    return true
end)
