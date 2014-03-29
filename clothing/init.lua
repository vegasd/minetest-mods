minetest.register_on_player_receive_fields(function(player, formname, fields)
    print(formname)
    print(dump(fields))
end)
