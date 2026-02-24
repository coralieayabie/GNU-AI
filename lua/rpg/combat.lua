-- Système de combat RPG
local Dice = require("rpg.dice")

local Combat = {}

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

function Combat.execute_turn(combat)
    combat.turn_count = combat.turn_count + 1

    -- Tour du joueur
    if combat.current_turn == "player" then
        -- Calcul des dégâts
        local damage = math.max(1, combat.player.attributes.strength + Dice.roll_d6() - combat.monster.armor)

        -- Appliquer les dégâts
        combat.monster.health = math.max(0, combat.monster.health - damage)

        -- Vérifier si le monstre est vaincu
        if combat.monster.health <= 0 then
            combat.is_active = false
            return true, "victoire"
        end

        -- Passer au tour du monstre
        combat.current_turn = "monster"

    -- Tour du monstre
    else
        -- Calcul des dégâts
        local damage = math.max(1, combat.monster.damage + Dice.roll_d6() - combat.player.attributes.endurance)

        -- Appliquer les dégâts
        combat.player.health = math.max(0, combat.player.health - damage)

        -- Vérifier si le joueur est vaincu
        if combat.player.health <= 0 then
            combat.is_active = false
            return true, "défaite"
        end

        -- Passer au tour du joueur
        combat.current_turn = "player"
    end

    return true, "en_cours"
end

function Combat.execute_full_combat(player, monster)
    local combat = Combat.create_combat_session(player, monster)

    while combat.is_active do
        local success, status = Combat.execute_turn(combat)
    end

    return combat
end

return Combat

