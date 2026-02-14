-- main_irc.lua - Programme principal avec IRC et RPG

local IRCClient = require("irc_client")

-- Configuration du bot
local config = {
    server = "irc.libera.chat",
    port = 6667,
    nickname = "GNU_AI_Bot",
    channel = "#gnu-ai-test",
    realname = "GNU AI RPG Bot",
    username = "gnu_ai"
}

-- Fonction principale
local function main()
    print("=== GNU-AI Bot IRC + RPG ===")
    print("🤖 Bot IRC avec système de jeu de rôle intégré")
    print("📖 Commandes disponibles: !help, !createplayer, !createmonster, !fight, !stats, !roll")
    
    -- Créer le client IRC
    local client = IRCClient.new(config)
    
    -- Exécuter le client IRC
    print("\n🚀 Démarrage du bot IRC...")
    client:run()
    
    print("\n✅ Bot IRC arrêté")
end

-- Exécuter le programme principal
main()