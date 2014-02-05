MESSAGES_ON_SCREEN = 10
MAX_LENGTH         = 30
LEFT_INDENT        = 0.01
TOP_INDENT         = 0.92
FONT_WIDTH         = 12
FONT_HEIGHT        = 28

chat_colors = {
    ooc     = 0xF0A010,
    help    = 0x10F0F0,
    scream  = 0xFFFFFF,
    normal  = 0xFFFFFF,
    whisper = 0xFFFFFF,
    action  = 0x10F010
}

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
            offset = {x=0, y=-i*FONT_HEIGHT}
        })
        print("ADDED HUD: " .. hud_id)
    end
end

function addMessage(player, nickname, message)
    local new_text = nickname .. ": " .. message

    for id=0,MESSAGES_ON_SCREEN-1 do
        local temp = player:hud_get(id).text
        player:hud_change(id, "text", new_text)
        new_text = temp
    end
end

minetest.register_on_joinplayer(function(player)
    minetest.after(1, createChatHUD, player)
end)

minetest.register_on_chat_message(function(name,message)
    local player = minetest.get_player_by_name("singleplayer")
    addMessage(player, name, message)

    return true
end)
