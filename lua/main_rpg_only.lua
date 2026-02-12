-- main_rpg_only.lua - Version du programme principal sans dépendance web
-- Parfait pour tester le RPG sans avoir à installer LuaSocket

local RPGAgent = require("rpg.rpg_agent")

-- Fonction principale
local function main()
    print("=== GNU-AI RPG Edition (sans dépendances) ===")
    print("Bienvenue dans le système RPG intégré à GNU-AI!")
    print("Cette version ne nécessite aucune dépendance externe.")
    
    -- Créer et exécuter l'agent RPG
    local rpg_agent = RPGAgent.create_rpg_agent()
    local context = rpg_agent.context
    
    -- Exécuter l'agent RPG
    rpg_agent.execute(context)
    
    -- Interface interactive simple
    print("\n=== MODE INTERACTIF RPG ===")
    print("Tapez 'quit' pour quitter, 'help' pour l'aide")
    
    while true do
        io.write("> ")
        local input = io.read()
        
        if not input or input:lower() == "quit" or input:lower() == "exit" then
            break
        end
        
        if input:lower() == "help" then
            print("\nCommandes disponibles:")
            print("  help - Affiche cette aide")
            print("  createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>")
            print("  createmonster <nom> <classe> <niveau>")
            print("  roll <nombre> - Lance des dés")
            print("  stats <player/monster> <nom>")
            print("  listclasses - Liste les classes")
            print("  quit/exit - Quitte le programme")
            print("\nClasses disponibles:")
            print("  Personnages: mage, humain, hobbit, elfe")
            print("  Monstres: loup_garou, vampire")
        else
            local result = rpg_agent.execute_command(input, context)
            print(result)
        end
    end
    
    print("\n✅ Merci d'avoir utilisé GNU-AI RPG!")
    print("🎮 À bientôt pour de nouvelles aventures!")
end

-- Exécuter le programme principal
main()