-- main_irc_improved.lua - Point d'entrée du bot IRC
local IRCBot = require("irc_bot")

local function main()
    print("##############################################################")
    print("###### GNU-AI Bot IRC - RPG + AI Integration (v1.0) ######")
    print("##############################################################")
    print("Commandes disponibles:")
    print("!createplayer, !createmonster, !generatemonster, !generatequest")
    print("!roll, !stats, !fight, !describe, !ai, !help")

    local bot = IRCBot.new()
    bot:run()
end

main()

