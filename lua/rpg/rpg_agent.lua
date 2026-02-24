-- Agent RPG principal
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
        rpg_commands = RPGCommands
    }
    return self
end

function RPGAgent:execute(context)
    print("=== AGENT RPG GNU-AI ===")
    print("Système de jeu de rôle intégré avec succès!")
end

function RPGAgent:execute_command(command_str, context)
    -- Passer le contexte complet aux commandes
    return context.rpg_commands.execute_command(command_str, {
        characters = context.characters,
        monsters = context.monsters,
        ai = context.ai,
        ai_monsters = context.ai_monsters,
        ai_quests = context.ai_quests
    })
end

return RPGAgent

