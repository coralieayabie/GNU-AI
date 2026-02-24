-- rpg/commands.lua - Version corrigée
local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local Combat = require("rpg.combat")

local RPGCommands = {}

-- Liste complète des commandes
local COMMAND_HELP = {
    -- ... (ton code existant pour COMMAND_HELP)
}

-- Fonction pour afficher l'aide
function RPGCommands.show_help()
    -- ... (ton code existant)
end

-- Fonction pour afficher une aide courte
function RPGCommands.show_short_help()
    return "Commandes disponibles: !help, !createplayer, !createmonster, !generatemonster, !generatequest, !roll, !stats, !fight, !describe, !ai, !listclasses. Tapez !help pour plus de détails."
end

-- Fonction principale d'exécution des commandes (CORRIGÉE)
function RPGCommands.execute_command(command_str, context)
    local parts = {}
    for word in command_str:gmatch("%S+") do
        table.insert(parts, word)
    end

    if #parts == 0 then
        return RPGCommands.show_short_help()
    end

    local cmd = parts[1]:lower()

    -- Commande HELP
    if cmd == "help" or cmd == "aide" then
        return RPGCommands.show_help()

    -- Commande ROLL (CORRIGÉE)
    elseif cmd == "roll" then
        local num_dice = tonumber(parts[2]) or 1
        return "🎲 " .. Dice.roll_and_format(num_dice)

    -- Commande CREATEPLAYER (CORRIGÉE)
    elseif cmd == "createplayer" then
        if #parts < 9 then
            return "Usage: createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>. Exemple: !createplayer Aragorn humain 5 20 20 15 15 10"
        end
        -- ... (le reste de ton code existant)

    -- Commande LISTCLASSES (CORRIGÉE)
    elseif cmd == "listclasses" then
        local char_classes = table.concat(RPGClasses.get_available_character_classes(), ", ")
        local monster_classes = table.concat(RPGClasses.get_available_monster_classes(), ", ")
        return "Classes disponibles:\nPersonnages: " .. char_classes .. "\nMonstres: " .. monster_classes

    -- Autres commandes...
    else
        return "Commande inconnue. " .. RPGCommands.show_short_help()
    end
end

return RPGCommands

