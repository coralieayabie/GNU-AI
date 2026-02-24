-- rpg/combat.lua - Système de combat RPG
local Dice = require("rpg.dice")
local Character = require("rpg.character")

local Combat = {}

-- Constantes de combat
local CRITICAL_HIT_CHANCE = 10
local CRITICAL_MULTIPLIER = 2
local DODGE_CHANCE_BASE = 15
local BLOCK_CHANCE_BASE = 20

function Combat.create_combat_session(player, monster)
    return {
        player = player,
        monster = {
            name = monster.name,
            class = monster.class,
            level = monster.level,
            health = monster.health,
            damage = monster.damage,
            armor = monster.armor,
            attributes = monster.attributes
        },
        current_turn = "player",
        turn_count = 0,
        log = {},
        is_active = true
    }
end

-- Fonctions de combat...
function Combat.execute_turn(combat)
    -- ... (ton code existant de combat)
end

function Combat.execute_full_combat(player, monster)
    -- ... (ton code existant)
end

return Combat

