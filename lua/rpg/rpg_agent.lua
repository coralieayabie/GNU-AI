-- rpg/rpg_agent.lua - Version corrigée
local AIBackend = require("ai_backend")
local AIMonsters = require("rpg.ai_monsters")
local AIQuests = require("rpg.ai_quests")
local RPGCommands = require("rpg.commands")
local config = require("config")

local RPGAgent = {}
RPGAgent.__index = RPGAgent

function RPGAgent.create_rpg_agent()
    local self = setmetatable({}, { __index = RPGAgent })

    local ai_backend = config.ai.enabled and AIBackend.new() or nil
    local ai_monsters = ai_backend and AIMonsters.new(ai_backend) or nil
    local ai_quests = ai_backend and AIQuests.new(ai_backend) or nil

    self.context = {
        characters = {},
        monsters = {},
        ai = ai_backend,
        ai_monsters = ai_monsters,
        ai_quests = ai_quests,
    }
    return self
end

function RPGAgent:execute(context)
    print("=== AGENT RPG GNU-AI ===")
    print("Système de jeu de rôle intégré avec succès!")
end

-- Fonction d'exécution des commandes corrigée
function RPGAgent:execute_command(command_str, context)
    -- Vérifier si la commande est vide
    if not command_str or command_str == "" then
        return RPGCommands.show_short_help()
    end

    -- Extraire la commande principale
    local cmd = command_str:match("^%w+")
    if not cmd then
        return RPGCommands.show_short_help()
    end

    -- Passer à RPGCommands
    return RPGCommands.execute_command(command_str, context)
end

return RPGAgent

