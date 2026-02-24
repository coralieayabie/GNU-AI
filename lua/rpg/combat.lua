-- rpg/combat.lua - Système de combat
local Dice = require("rpg.dice")

local Combat = {}

function Combat.create_combat_session(player, monster)
    return {
        player = player,
        monster = monster,
        current_turn = "player",
        turn_count = 0,
        log = {},
        is_active = true
    }
end

function Combat.execute_turn(combat)
    -- Implémentation simplifiée pour l'exemple
    combat.turn_count = combat.turn_count + 1
    combat.is_active = false
    return true, "victoire"
end

function Combat.execute_full_combat(player, monster)
    local combat = Combat.create_combat_session(player, monster)
    Combat.execute_turn(combat)
    return combat
end

return Combat

