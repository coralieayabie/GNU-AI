-- main.lua - Programme principal avec intégration RPG et IRC

local RPGAgent = require("rpg.rpg_agent")

-- Fonction principale
local function main()
    print("=== GNU-AI avec RPG et IRC ===")
    print("Système de jeu de rôle et client IRC intégré")
    
    -- Créer et exécuter l'agent RPG
    local rpg_agent = RPGAgent.create_rpg_agent()
    local rpg_context = rpg_agent.context
    
    print("\n1. Exécution de l'agent RPG...")
    rpg_agent.execute(rpg_context)
    
    -- Afficher les résultats RPG
    if rpg_context.rpg_results then
        print("\n2. Résultats RPG:")
        print("- Personnage créé: " .. tostring(rpg_context.rpg_results.player_created))
        print("- Monstre créé: " .. tostring(rpg_context.rpg_results.monster_created))
        print("- Dés lancés: " .. tostring(rpg_context.rpg_results.dice_rolled))
        print("- Classes disponibles: " .. #rpg_context.rpg_results.available_character_classes .. " personnages, " .. #rpg_context.rpg_results.available_monster_classes .. " monstres")
    end
    
    print("\n✅ Agent RPG prêt!")
    print("📝 Le système IRC sera intégré prochainement...")
end

-- Exécuter le programme principal
main()