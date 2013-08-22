-- config zone {{{
FMT_OOC = "%q (OOC): (( %q ))"
FMT_SHOUT = "%q (shouts): %q"
FMT_WHISPER = "%q (whispers): %q"
FMT_ME = "* %q %q"
FMT_NORMAL = "%q: %q"

RANGE_NORMAL = 18
RANGE_SHOUT = 68
RANGE_WHISPER = 3

GM_PREFIX = "[GM] "
-- config zone }}}

minetest.register_privilege("allchat", "Gives accses to reading all messages in the chat")

minetest.register_on_chat_message(function(name, message)

pl = minetest.get_player_by_name(name)
pls = minetest.get_connected_players()

sym = message[:1]
submes = message[2:]

-- GM's prefix
if minetest.check_player_privs(name) then
    showname = GM_PREFIX .. name
end

globalchat = false

if sym == "?" then
    fmt = FMT_OOC
    globalchat = true
    range = 68 
elseif sum == "_"  then
    fmt = FMR_OOC
    range = RANGE_NORMAL
elseif sym == "!" then
    fmt = FMT_SHOUT
    range = RANGE_SHOUT
elseif sym == "=" then
    fmt = FMT_WHISPER
    range = RANGE_WHISPER
elseif sym = "*" then
    fmt = FMT_ME
    range = RANGE_NORMAL
else
    fmt = FMT_NORMAL
    submes = message
    range = RANGE_NORMAL
end

for i = 1, #pls do
    if (math.sqrt((pl:getpos().x-pls[i]:getpos().x)^2 +(pl:getpos().y-pls[i]:getpos().y)^2+(pl:getpos().z-pls[i]:getpos().z)^2)<range
        and not(name == pls[i]:get_player_name()))
        or (minetest.check_player_privs(pls[i]:get_player_name(), {allchat=true}))-- for DSs or KAOS
        or (globalchat)
        then minetest.chat_send_player(pls[i]:get_player_name(), string.format(fmt, showname, submes), false)
    end
end

return true
end)
