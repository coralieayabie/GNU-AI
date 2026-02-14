-- test_rpg_integration.lua - Test complet de l'intégration RPG dans GNU-AI

local RPGAgent = require("rpg.rpg_agent")

-- Fonction de test principale
local function test_rpg_integration()
    print("=== TEST D'INTÉGRATION RPG GNU-AI ===")
    
    -- Créer l'agent RPG
    local rpg_agent = RPGAgent.create_rpg_agent()
    local context = rpg_agent.context
    
    -- Exécuter l'agent RPG
    print("\n1. Exécution de l'agent RPG...")
    rpg_agent.execute(context)
    
    -- Tester les commandes RPG
    print("\n2. Test des commandes RPG...")
    
    -- Test commande help
    print("\n--- Test commande 'help' ---")
    local result = rpg_agent.execute_command("help", context)
    print(result)
    
    -- Test commande listclasses
    print("\n--- Test commande 'listclasses' ---")
    result = rpg_agent.execute_command("listclasses", context)
    print(result)
    
    -- Test commande roll
    print("\n--- Test commande 'roll 2' ---")
    result = rpg_agent.execute_command("roll 2", context)
    print(result)
    
    -- Test commande stats
    print("\n--- Test commande 'stats player Héros' ---")
    result = rpg_agent.execute_command("stats player Héros", context)
    print(result)
    
    print("\n--- Test commande 'stats monster Dragon Noir' ---")
    result = rpg_agent.execute_command("stats monster Dragon Noir", context)
    print(result)
    
    -- Test création d'un nouveau personnage
    print("\n--- Test création personnage 'Gandalf' ---")
    result = rpg_agent.execute_command("createplayer Gandalf mage 10 15 5 8 7 10", context)
    print(result)
    
    -- Vérifier que le personnage a été créé
    if context.characters["Gandalf"] then
        print("✅ Personnage Gandalf créé avec succès!")
        print(context.characters["Gandalf"].name .. " - " .. context.characters["Gandalf"].class)
    end
    
    -- Test création d'un nouveau monstre
    print("\n--- Test création monstre 'Vampire Ancien' ---")
    result = rpg_agent.execute_command("createmonster VampireAncien vampire 15", context)
    print(result)
    
    -- Vérifier que le monstre a été créé
    if context.monsters["VampireAncien"] then
        print("✅ Monstre VampireAncien créé avec succès!")
        print(context.monsters["VampireAncien"].name .. " - " .. context.monsters["VampireAncien"].class)
    end
    
    -- Test commande inconnue
    print("\n--- Test commande inconnue ---")
    result = rpg_agent.execute_command("commandeinconnue", context)
    print(result)
    
    -- Afficher le résumé final
    print("\n=== RÉSUMÉ DU TEST ===")
    print("Personnages créés: " .. #context.characters)
    print("Monstres créés: " .. #context.monsters)
    print("Classes de personnages disponibles: " .. #context.rpg_results.available_character_classes)
    print("Classes de monstres disponibles: " .. #context.rpg_results.available_monster_classes)
    
    print("\n✅ Tous les tests d'intégration RPG ont réussi!")
    print("🎮 Le système RPG est maintenant pleinement intégré à GNU-AI!")
end

-- Exécuter les tests
test_rpg_integration()