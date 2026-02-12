-- main.lua - Programme principal en Lua
-- Équivalent de main.c

local Agent = require("agent")
local Web = require("web")

-- Fonction principale - Équivalent de main()
local function main()
    -- Créer le contexte web - Équivalent de WebContext ctx
    local ctx = Web.WebContext.new("doc sur les LLM")
    
    -- Créer l'agent web - Équivalent de create_agent
    local web_agent = Agent.new("WebSearchAgent", Web.web_search_agent_execute, ctx)
    
    -- Exécuter l'agent - Équivalent de web_agent->execute(web_agent->context)
    web_agent:run()
    
    -- Afficher les résultats - Équivalent du printf
    if ctx.result and ctx.result ~= "" then
        print("Résultat de la recherche: " .. ctx.result)
    else
        print("Aucun résultat obtenu.")
    end
    
    -- Nettoyer - Équivalent de destroy_agent
    web_agent:destroy()
end

-- Exécuter le programme principal
main()