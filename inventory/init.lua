minetest.register_chatcommand("inv_test", {
    func = function()
        -- Called when command is run.
        -- Returns boolean success and text output.
        local inv = minetest.get_inventory({type = "player", name = "singleplayer"})
        print(dump(inv:get_lists()))
    end
})

minetest.register_on_joinplayer(function(player)
    local invref = player:get_inventory()
    -- Something wrong
    -- invref:set_lists({wear, main})
    --
    -- TODO: Set size and formspec
end)
