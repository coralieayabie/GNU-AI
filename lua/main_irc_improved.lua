-- main_irc_improved.lua - Bot IRC amélioré inspiré de RGP-IRC_GAME

local IRCBot = require("irc_bot")

-- Fonction principale
local function main()
    print("##################################################################")
    print("######        GNU-AI Bot IRC Amélioré - RPG + IRC          #####")
    print("######    Inspiré de RGP-IRC_GAME avec système de combat  ######")
    print("##################################################################")
    print("--> Commandes disponibles:")
    print("  !createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>")
    print("  !createmonster <nom> <classe> <niveau>")
    print("  !fight <joueur> <monstre>")
    print("  !roll <nombre>")
    print("  !stats <player/monster> <nom>")
    print("  !listclasses")
    print("  !help, !ping, !version")
    
    -- Créer et exécuter le bot IRC
    local bot = IRCBot.new()
    bot:run()
    
    print("--> Bot IRC arrêté proprement")
end

-- Exécuter le programme principal
main()
