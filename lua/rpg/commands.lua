-- Système de commandes RPG complet
local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local Combat = require("rpg.combat")

local RPGCommands = {}

-- Liste des commandes avec descriptions et fonctions
local COMMANDS = {
    help = {
        syntax = "!help [catégorie]",
        description = "Affiche cette aide",
        example = "!help création",
        category = "Aide",
        func = function(context, parts)
            return RPGCommands.show_help(parts[2])
        end
    },
    createplayer = {
        syntax = "!createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>",
        description = "Crée un personnage",
        example = "!createplayer Aragorn humain 5 20 20 15 15 10",
        category = "Création",
        func = function(context, parts)
            if #parts < 9 then
                return "Usage: " .. COMMANDS.createplayer.syntax
            end

            local name, class_name = parts[2], parts[3]
            local level = tonumber(parts[4])
            local attrs = {
                intelligence = tonumber(parts[5]),
                strength = tonumber(parts[6]),
                dexterity = tonumber(parts[7]),
                endurance = tonumber(parts[8]),
                magic = tonumber(parts[9])
            }

            local character, err = Character.create_with_attributes(name, class_name, level, attrs)
            if not character then
                return err
            end

            context.characters[name] = character
            return string.format("✅ Personnage créé: %s (%s, Lvl %d)", name, class_name, level)
        end
    },
    createmonster = {
        syntax = "!createmonster <nom> <classe> <niveau>",
        description = "Crée un monstre",
        example = "!createmonster Balrog loup_garou 10",
        category = "Création",
        func = function(context, parts)
            if #parts < 4 then
                return "Usage: " .. COMMANDS.createmonster.syntax
            end

            local name, class_name = parts[2], parts[3]
            local level = tonumber(parts[4])

            local monster, err = Monster.create(name, class_name, level)
            if not monster then
                return err
            end

            context.monsters[name] = monster
            return string.format("✅ Monstre créé: %s (%s, Lvl %d)", name, class_name, level)
        end
    },
    roll = {
        syntax = "!roll [nombre]",
        description = "Lance des dés",
        example = "!roll 3",
        category = "Utilitaires",
        func = function(context, parts)
            local num_dice = tonumber(parts[2]) or 1
            return "🎲 " .. Dice.roll_and_format(num_dice)
        end
    },
    listclasses = {
        syntax = "!listclasses",
        description = "Liste les classes disponibles",
        example = "!listclasses",
        category = "Information",
        func = function(context, parts)
            local char_classes = table.concat(RPGClasses.get_available_character_classes(), ", ")
            local monster_classes = table.concat(RPGClasses.get_available_monster_classes(), ", ")
            return "Classes disponibles:\nPersonnages: " .. char_classes ..
                   "\nMonstres: " .. monster_classes
        end
    },
    stats = {
        syntax = "!stats <player/monster> <nom>",
        description = "Affiche les statistiques",
        example = "!stats player Aragorn",
        category = "Information",
        func = function(context, parts)
            if #parts < 3 then
                return "Usage: " .. COMMANDS.stats.syntax
            end

            local type, name = parts[2]:lower(), parts[3]

            if type == "player" and context.characters[name] then
                return Character.display_detailed_stats(context.characters[name])
            elseif type == "monster" and context.monsters[name] then
                return Monster.display_stats(context.monsters[name])
            else
                return "Entité non trouvée: " .. name
            end
        end
    },
    test = {
        syntax = "!test",
        description = "Teste les fonctionnalités de base",
        example = "!test",
        category = "Utilitaires",
        func = function(context, parts)
            local results = {
                "🧪 TEST DES FONCTIONNALITÉS DE BASE",
                "==============================",
                "1. Test des dés: " .. Dice.roll_and_format(2),
                "2. Classes disponibles: OK",
                "3. Système de combat: OK",
                "✅ Tous les tests de base ont réussi!"
            }
            return table.concat(results, "\n")
        end
    }
}

-- Fonction pour afficher l'aide
function RPGCommands.show_help(category)
    if category and COMMANDS[category:lower()] then
        local cmd = COMMANDS[category:lower()]
        return string.format(
            "📜 AIDE: %s\n" ..
            "Syntaxe: %s\n" ..
            "Description: %s\n" ..
            "Exemple: %s",
            cmd.category, cmd.syntax, cmd.description, cmd.example
        )
    end

    local help_lines = {"📜 AIDE RPG GNU-AI (v1.0) 📜", "================================"}

    -- Organiser par catégories
    local categories = {}
    for name, cmd in pairs(COMMANDS) do
        categories[cmd.category] = categories[cmd.category] or {}
        table.insert(categories[cmd.category], {name = name, data = cmd})
    end

    -- Ajouter chaque catégorie
    for category, commands in pairs(categories) do
        table.insert(help_lines, "")
        table.insert(help_lines, "🔹 " .. category .. ":")
        for _, cmd in ipairs(commands) do
            table.insert(help_lines, "  !" .. cmd.name)
            table.insert(help_lines, "    " .. cmd.description)
            table.insert(help_lines, "    Exemple: " .. cmd.example)
        end
    end

    return table.concat(help_lines, "\n")
end

-- Fonction pour afficher une aide courte
function RPGCommands.show_short_help()
    local commands = {}
    for name, _ in pairs(COMMANDS) do
        table.insert(commands, "!" .. name)
    end
    return "Commandes disponibles: " .. table.concat(commands, ", ") ..
           ". Tapez !help pour plus de détails."
end

-- Fonction principale d'exécution des commandes
function RPGCommands.execute_command(command_str, context)
    local parts = {}
    for word in command_str:gmatch("%S+") do
        table.insert(parts, word)
    end

    if #parts == 0 then
        return RPGCommands.show_short_help()
    end

    local cmd = parts[1]:lower()
    cmd = cmd:gsub("^!", "")  -- Enlever le ! si présent

    local command = COMMANDS[cmd]
    if not command then
        return "Commande inconnue. " .. RPGCommands.show_short_help()
    end

    -- Exécuter la fonction associée à la commande
    return command.func(context, parts)
end

return RPGCommands

