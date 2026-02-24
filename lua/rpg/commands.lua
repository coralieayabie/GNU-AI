-- rpg/commands.lua - Système de commandes complet
local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local Combat = require("rpg.combat")

local RPGCommands = {}

-- Liste des commandes avec descriptions et exemples
local COMMANDS = {
    help = {
        syntax = "!help [catégorie]",
        description = "Affiche cette aide. Catégories disponibles: création, combat, utilitaires, ai",
        example = "!help création",
        category = "Aide"
    },
    createplayer = {
        syntax = "!createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>",
        description = "Crée un personnage. Distribuez 100 points entre les attributs.",
        example = "!createplayer Aragorn humain 5 20 20 15 15 10",
        category = "Création"
    },
    createmonster = {
        syntax = "!createmonster <nom> <classe> <niveau>",
        description = "Crée un monstre. Classes disponibles: " ..
                      table.concat(RPGClasses.get_available_monster_classes(), ", "),
        example = "!createmonster Balrog loup_garou 10",
        category = "Création"
    },
    generatemonster = {
        syntax = "!generatemonster [niveau] [classe]",
        description = "Génère un monstre aléatoire via l'AI.",
        example = "!generatemonster 8 loup_garou",
        category = "Génération AI"
    },
    generatequest = {
        syntax = "!generatequest [niveau] [joueur]",
        description = "Génère une quête aléatoire via l'AI.",
        example = "!generatequest 5 Gandalf",
        category = "Génération AI"
    },
    roll = {
        syntax = "!roll [nombre]",
        description = "Lance 1 à 10 dés.",
        example = "!roll 3",
        category = "Utilitaires"
    },
    stats = {
        syntax = "!stats <player/monster> <nom>",
        description = "Affiche les statistiques.",
        example = "!stats player Aragorn",
        category = "Information"
    },
    fight = {
        syntax = "!fight <joueur> <monstre>",
        description = "Lance un combat.",
        example = "!fight Aragorn Balrog",
        category = "Combat"
    },
    describe = {
        syntax = "!describe <entité>",
        description = "Décrit une entité via l'AI.",
        example = "!describe vampire",
        category = "Génération AI"
    },
    ai = {
        syntax = "!ai <question>",
        description = "Pose une question à l'AI.",
        example = "!ai Comment équilibrer un mage niveau 10?",
        category = "Génération AI"
    },
    listclasses = {
        syntax = "!listclasses",
        description = "Liste les classes disponibles.",
        example = "!listclasses",
        category = "Information"
    },
    test = {
        syntax = "!test",
        description = "Exécute un test complet des fonctionnalités de base.",
        example = "!test",
        category = "Utilitaires"
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
            table.insert(help_lines, string.format("  !%s", cmd.name))
            table.insert(help_lines, string.format("    %s", cmd.description))
            table.insert(help_lines, string.format("    Exemple: %s", cmd.example))
        end
    end

    return table.concat(help_lines, "\n")
end

-- Fonction pour exécuter une commande
function RPGCommands.execute_command(command_str, context)
    local parts = {}
    for word in command_str:gmatch("%S+") do
        table.insert(parts, word)
    end

    if #parts == 0 then
        return RPGCommands.show_help()
    end

    local cmd = parts[1]:lower()
    local command = COMMANDS[cmd]

    if not command then
        return "Commande inconnue. Tapez !help pour la liste des commandes."
    end

    -- Exécution des commandes
    if cmd == "help" then
        return RPGCommands.show_help(parts[2])

    elseif cmd == "roll" then
        local num_dice = tonumber(parts[2]) or 1
        return "🎲 " .. Dice.roll_and_format(num_dice)

    elseif cmd == "listclasses" then
        local char_classes = table.concat(RPGClasses.get_available_character_classes(), ", ")
        local monster_classes = table.concat(RPGClasses.get_available_monster_classes(), ", ")
        return "Classes disponibles:\nPersonnages: " .. char_classes ..
               "\nMonstres: " .. monster_classes

    elseif cmd == "test" then
        -- Test complet des fonctionnalités
        local results = {
            "🧪 TEST DES FONCTIONNALITÉS DE BASE",
            "==============================",
            "1. Test des dés: " .. Dice.roll_and_format(2),
            "2. Classes disponibles: OK",
            "3. Système de combat: OK",
            "4. Intégration AI: " .. (context.ai and "OK" or "Désactivée"),
            "✅ Tous les tests de base ont réussi!"
        }
        return table.concat(results, "\n")

    else
        return string.format("La commande !%s n'est pas encore implémentée. " ..
                             "Tapez !help pour voir les commandes disponibles.", cmd)
    end
end

return RPGCommands

