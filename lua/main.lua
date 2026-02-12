-- main.lua - Programme principal en Lua
-- Équivalent de main.c avec intégration RPG

local Agent = require("agent")
local Web = require("web")
local RPGAgent = require("rpg.rpg_agent")

-- Fonction principale - Équivalent de main()
local function main()
    print("=== GNU-AI avec intégration RPG ===")
    
    -- Créer le contexte web - Équivalent de WebContext ctx
    local web_ctx = Web.WebContext.new("doc sur les LLM")
    
    -- Créer l'agent web - Équivalent de create_agent
    local web_agent = Agent.new("WebSearchAgent", Web.web_search_agent_execute, web_ctx)
    
    -- Créer et exécuter l'agent RPG
    local rpg_agent = RPGAgent.create_rpg_agent()
    local rpg_context = rpg_agent.context
    
    print("\n1. Exécution de l'agent RPG...")
    rpg_agent.execute(rpg_context)
    
    print("\n2. Exécution de l'agent Web...")
    -- Exécuter l'agent - Équivalent de web_agent->execute(web_agent->context)
    web_agent:run()
    
    -- Afficher les résultats web - Équivalent du printf
    if web_ctx.result and web_ctx.result ~= "" then
        print("Résultat de la recherche: " .. web_ctx.result)
    else
        print("Aucun résultat web obtenu.")
    end
    
    -- Afficher les résultats RPG
    if rpg_context.rpg_results then
        print("\n3. Résultats RPG:")
        print("- Personnage créé: " .. tostring(rpg_context.rpg_results.player_created))
        print("- Monstre créé: " .. tostring(rpg_context.rpg_results.monster_created))
        print("- Dés lancés: " .. tostring(rpg_context.rpg_results.dice_rolled))
        print("- Classes disponibles: " .. #rpg_context.rpg_results.available_character_classes .. " personnages, " .. #rpg_context.rpg_results.available_monster_classes .. " monstres")
    end
    
    -- Nettoyer - Équivalent de destroy_agent
    web_agent:destroy()
    print("\n✅ Tous les agents ont terminé leur exécution!")
end

-- Exécuter le programme principal
main()