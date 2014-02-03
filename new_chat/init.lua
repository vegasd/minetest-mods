MESSAGES_ON_SCREEN=10
LEFT_INDENT=0.05

minetest.register_on_chat_message(function(name,message)
    local player = minetest.get_player_by_name(name)
    local hud_id = player:hud_add({
        hud_elem_type = "text",
        text = message,
        position = {x = LEFT_INDENT, y = 0.9},
        name = "chat",
        scale = {x=500, y=50},
        number = 0xFFFFFF,
        item = 0,
        direction = 0,
        alignment = {x=1, y=0},
        offset = {x=0, y=0}
    })
    print("ADDED HUD: " .. hud_id)
    
    local start_id
    if hud_id == MESSAGES_ON_SCREEN then start_id = 0
    else start_id = hud_id + 1 end

    print(end_id)

    for id = start_id,hud_id+MESSAGES_ON_SCREEN+1 do
        print("FOR id = " .. id)
        if id >= MESSAGES_ON_SCREEN then
            local real_id = id - MESSAGES_ON_SCREEN - 1

            local hud = player:hud_get(real_id)
            if hud ~= nil then 
                print(dump(hud))
                player:hud_change(real_id, position,
                    {x = LEFT_INDENT, y = 0.5})
                print(dump(hud))
            end
        else
            local hud = player:hud_get(id)
            if hud ~= nil then 
                player:hud_change(id, position,
                    {x = LEFT_INDENT, y = hud.position.y + 0.5/MESSAGES_ON_SCREEN})
            end
        end
    end
    
    return true
end)
