-- main_irc_improved.lua - Point d'entrée
local IRCBot = require("irc_bot")

local function main()
    print("##############################################################")
    print("###### GNU-AI Bot IRC - RPG + AI Integration (v1.0) ######")
    print("##############################################################")
    print("Commandes disponibles:")
    print("!help, !test, !roll, !listclasses, !createplayer, etc.")

    local bot = IRCBot.new()
    bot:run()
end

main()

