MESSAGES_ON_SCREEN = 10
MAX_LENGTH         = 30
LEFT_INDENT        = 0.00
TOP_INDENT         = 0.92
FONT_WIDTH         = 12
FONT_HEIGHT        = 28

function createChatHUD(player)
    for i=1,MESSAGES_ON_SCREEN do
        local hud_id = player:hud_add({
            hud_elem_type = "text",
            text = i,
            position = {x = LEFT_INDENT, y = TOP_INDENT},
            name = "chat",
            scale = {x=500, y=50},
            number = 0xFFFFFF,
            item = 0,
            direction = 0,
            alignment = {x=1, y=0},
            offset = {x=FONT_WIDTH*16+4, y=-i*FONT_HEIGHT}
        })
        print("ADDED HUD: " .. hud_id)
    end
end

minetest.register_on_joinplayer(function(player)
    minetest.after(1, createChatHUD, player)
end)
