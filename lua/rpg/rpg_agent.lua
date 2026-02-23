-- rpg/rpg_agent.lua - Intégration de l'AIBackend
local AIBackend = require("ai_backend")
local config = require("config")

local RPGAgent = {}
RPGAgent.__index = RPGAgent

-- Créer un agent RPG avec support AI
function RPGAgent.create_rpg_agent()
    local self = setmetatable({}, { __index = RPGAgent })
    self.context = {
        characters = {},
        monsters = {},
        ai = config.ai.enabled and AIBackend.new(config.ai) or nil,
    }
    return self
end

-- Commandes existantes (exemple: createplayer)
function RPGAgent:execute_command(command_str, context)
    local parts = {}
    for word in command_str:gmatch("%S+") do
        table.insert(parts, word)
    end
    if #parts == 0 then return "Erreur: commande vide" end

    local cmd = parts[1]:lower()

    -- Commandes classiques
    if cmd == "createplayer" then
        -- ... ton code existant ...
    elseif cmd == "help" or cmd == "aide" then
        if context.ai then
            local prompt = "Aide pour un jeu de rôle Lua/IRC. Liste les commandes: createplayer, createmonster, roll, stats, fight. Sois concis et en français."
            return context.ai:get_response(prompt)
        else
            return "Commandes: !createplayer, !createmonster, !roll, !stats, !fight, !listclasses"
        end
    elseif cmd == "describe" and #parts >= 2 then
        if context.ai then
            local target = parts[2]
            return context.ai:get_response("Décris '" .. target .. "' pour un RPG fantasy, en 2 phrases max.")
        else
            return "Description de " .. parts[2] .. " indisponible."
        end
    elseif cmd == "quest" then
        if context.ai then
            local level = parts[2] or "5"
            return context.ai:get_response("Génère une quête pour un personnage niveau " .. level .. " dans un RPG fantasy. Format: [Titre] - [Description] - Récompense: [XP/Or]")
        else
            return "Quête aléatoire: 'Tuer 3 loups' - Récompense: 50 XP"
        end
    end
    return "Commande inconnue. Utilisez !help."
end

return RPGAgent

