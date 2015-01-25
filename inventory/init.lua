inventory = {}

minetest.register_chatcommand("inv_test", {
    func = function()
        -- Called when command is run.
        -- Returns boolean success and text output.
        local inv = minetest.get_inventory({type = "player", name = "singleplayer"})
        print(dump(inv:get_lists()))
    end
})

minetest.register_on_newplayer(function(player)
    local invref = player:get_inventory()

    -- Main list
    invref:set_size("main", 9)

    -- Wear list, for clothes
    invref:set_list("wear", {})
    invref:set_size("wear", 36)

    -- Left and right hand (is this needed?)
    --invref:set_list("left_hand", {})
    --invref:set_size("left_hand", 1)
    --invref:set_list("right_hand", {})
    --invref:set_size("right_hand", 1)
end)

minetest.register_on_joinplayer(function(player)
	if not minetest.setting_getbool("creative_mode") then
		player:set_inventory_formspec(inventory.gui_survival_form)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "" then
        if fields.craft_inv then
            print("Craft and inventory")
        elseif fields.wear_inv then
            print("Clothing")
        elseif fields.notes_inv then
            print("Some place for quick notes")
        end
    end
    print("For debug (from inventory mod) inv. fields:",dump(fields))
end)

inventory.inventory_buttons = 
    "button[0.25,4.9;2.5,0.1;craft_inv;Inventory]"..
    "button[3.25,4.9;2.5,0.1;wear_inv;Clothes]"..
    "button[6.25,4.9;2.5,0.1;notes_inv;Notes]"

inventory.gui_survival_form =
    -- Basic setup
    "size[9,5]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..

    -- Craft
    "list[current_player;craft;2,0;3,3;]"..
    "image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
    "list[current_player;craftpreview;6,1;1,1;]"..

    -- Left and right hand
    --"list[current_player;left_hand;0.25,1;1,1;]"..
    --"list[current_player;right_hand;7.75,1;1,1;]"..
    
    -- Main inventory
    "list[current_player;main;0,3.5;9,1;]"..

    -- Buttons
    inventory.inventory_buttons
