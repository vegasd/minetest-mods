-- kmchat - a simple local chat mod for minetest
-- Copyright (C) 2013 hunterdelyx1, vegasd (Konungstvo Midgard)
--
-- This file is part of KMRP minetest-mods
--
-- KMRP minetest-mods is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- KMRP minetest-mods is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with KMRP minetest-mods.  If not, see <http://www.gnu.org/licenses/>.
--
-------------------------------------------------------------------------------
--
-- Features:
--  * Local chat
--  * Comfortable whisper and shout w/o commands
--  * Local and global OOC-chat
--  * GM-prefixes
--  * Dices

-- TODO: colorize chat (chat colors are not implemented in Minetest for now)


-- config zone {{{
FMT_OOC = "%s (OOC): (( %s ))"
FMT_SHOUT = "%s (shouts): %s"
FMT_WHISPER = "%s (whispers): %s"
FMT_ME = "* %s %s"
FMT_GM = "*** %s: %s ***"
FMT_NORMAL = "%s: %s"

RANGE_NORMAL = 18
RANGE_SHOUT = 68
RANGE_WHISPER = 3

GM_PREFIX = "[GM] "
-- config zone }}}


minetest.register_privilege("gm", "Gives accses to reading all messages in the chat")

minetest.register_on_chat_message(function(name, message)

pl = minetest.get_player_by_name(name)
pls = minetest.get_connected_players()

sym = message:sub(0,1)
submes = message:sub(2)

minetest.chat_send_player(name, "Everybody see:\n", false)

if sym == "?" and string.len(message) ~= 1 then
    fmt = FMT_OOC
    minetest.chat_send_all(string.format(fmt, showname, submes))
    return true
end

if sym == "_"  then
    fmt = FMT_OOC
    range = RANGE_NORMAL
elseif sym == "!" then
    fmt = FMT_SHOUT
    range = RANGE_SHOUT
elseif sym == "=" then
    fmt = FMT_WHISPER
    range = RANGE_WHISPER
elseif sym == "*" then
    fmt = FMT_ME
    range = RANGE_NORMAL
elseif sym == "#" and minetest.check_player_privs(name, {gm=true}) then
    fmt = FMT_GM
    range = RANGE_NORMAL
elseif sym == "d" and submes == "4" then
    fmt = "*** %s rolls d4 and result is %d ***"
    submes = math.random(4)
    range = RANGE_NORMAL
elseif sym == "d" and submes == "6" then
    fmt = "*** %s rolls d6 and result is %d ***"
    submes = math.random(6)
    range = RANGE_NORMAL
elseif sym == "d" and submes == "8" then
    fmt = "*** %s rolls d8 and result is %d ***"
    submes = math.random(8)
    range = RANGE_NORMAL
elseif sym == "d" and submes == "10" then
    fmt = "*** %s rolls d10 and result is %d ***"
    submes = math.random(10)
    range = RANGE_NORMAL
elseif sym == "d" and submes == "12" then
    fmt = "*** %s rolls d12 and result is %d ***"
    submes = math.random(12)
    range = RANGE_NORMAL
elseif sym == "d" and submes == "20" then
    fmt = "*** %s rolls d20 and result is %d ***"
    submes = math.random(20)
    range = RANGE_NORMAL
else
    fmt = FMT_NORMAL
    submes = message
    range = RANGE_NORMAL
end

-- GM's prefix
if minetest.check_player_privs(name, {gm=true,}) then
    showname = GM_PREFIX .. name
else
    showname = name
end

senderpos = pl:getpos()
for i = 1, #pls do
    recieverpos = pls[i]:getpos()
    if math.sqrt((senderpos.x-recieverpos.x)^2 + (senderpos.y-recieverpos.y)^2 + (senderpos.z-recieverpos.z)^2) < range then
        minetest.chat_send_player(pls[i]:get_player_name(), string.format(fmt, showname, submes), false)
    elseif minetest.check_player_privs(pls[i]:get_player_name(), {gm=true}) then
        -- for DSs or KAOS - TODO: make it differ from regular message
        minetest.chat_send_player(pls[i]:get_player_name(), "~~~ " .. string.format(fmt, showname, submes), false)
    end
end

return true
end 
)
