-- rpg/commands.lua - Système de commandes RPG complet
local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local Combat = require("rpg.combat")

local RPGCommands = {}

-- Liste complète des commandes avec descriptions et exemples
local COMMAND_HELP = {
    {
        command = "!createplayer",
        syntax = "!createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>",
        description = "Crée un nouveau personnage. Distribuez 100 points entre les 5 attributs (intelligence, force, dextérité, endurance, magie).",
        example = "!createplayer Aragorn humain 5 20 20 15 15 10",
        category = "Création"
    },
    {
        command = "!createmonster",
        syntax = "!createmonster <nom> <classe> <niveau>",
        description = "Crée un nouveau monstre. Classes disponibles: " ..
                      table.concat(RPGClasses.get_available_monster_classes(), ", "),
        example = "!createmonster Balrog vampire 15",
        category = "Création"
    },
    {
        command = "!generatemonster",
        syntax = "!generatemonster [niveau] [classe]",
        description = "Génère un monstre aléatoire via l'AI. Niveau par défaut: 5.",
        example = "!generatemonster 8 loup_garou",
        category = "Génération AI"
    },
    {
        command = "!generatequest",
        syntax = "!generatequest [niveau] [joueur]",
        description = "Génère une quête aléatoire via l'AI. Niveau par défaut: 5.",
        example = "!generatequest 5 Gandalf",
        category = "Génération AI"
    },
    {
        command = "!roll",
        syntax = "!roll [nombre]",
        description = "Lance 1 à 10 dés. Par défaut: 1 dé.",
        example = "!roll 3",
        category = "Utilitaires"
    },
    {
        command = "!stats",
        syntax = "!stats <player/monster> <nom>",
        description = "Affiche les statistiques détaillées d'un personnage ou monstre.",
        example = "!stats player Aragorn",
        category = "Information"
    },
    {
        command = "!fight",
        syntax = "!fight <joueur> <monstre>",
        description = "Lance un combat entre un joueur et un monstre.",
        example = "!fight Aragorn Balrog",
        category = "Combat"
    },
    {
        command = "!describe",
        syntax = "!describe <entité>",
        description = "Décrit une entité (monstre/classe) avec l'AI.",
        example = "!describe vampire",
        category = "Génération AI"
    },
    {
        command = "!ai",
        syntax = "!ai <question>",
        description = "Pose une question libre à l'AI.",
        example = "!ai Comment équilibrer un mage niveau 10?",
        category = "Génération AI"
    },
    {
        command = "!listclasses",
        syntax = "!listclasses",
        description = "Liste toutes les classes de personnages et monstres disponibles.",
        example = "!listclasses",
        category = "Information"
    }
}

-- Fonction pour afficher l'aide complète
function RPGCommands.show_help()
    local help_lines = {
        "📜 AIDE RPG GNU-AI (v1.0) 📜",
        "=================================",
        "Bienvenue dans le système RPG avancé avec IA!"
    }

    -- Organiser par catégories
    local categories = {}
    for _, cmd in ipairs(COMMAND_HELP) do
        categories[cmd.category] = categories[cmd.category] or {}
        table.insert(categories[cmd.category], cmd)
    end

    -- Ajouter chaque catégorie
    for category, commands in pairs(categories) do
        table.insert(help_lines, "")
        table.insert(help_lines, "🔹 " .. category .. ":")
        for _, cmd in ipairs(commands) do
            table.insert(help_lines, "  " .. cmd.syntax)
            table.insert(help_lines, "    " .. cmd.description)
            table.insert(help_lines, "    Exemple: " .. cmd.example)
        end
    end

    -- Ajouter les classes disponibles
    table.insert(help_lines, "")
    table.insert(help_lines, "🔸 CLASSES DISPONIBLES:")
    table.insert(help_lines, "  Personnages: " .. table.concat(RPGClasses.get_available_character_classes(), ", "))
    table.insert(help_lines, "  Monstres: " .. table.concat(RPGClasses.get_available_monster_classes(), ", "))

    -- Ajouter le système d'attributs
    table.insert(help_lines, "")
    table.insert(help_lines, "🔸 SYSTÈME D'ATTRIBUTS (100 pts):")
    table.insert(help_lines, "  intelligence: Magie et perception (+2 par point)")
    table.insert(help_lines, "  strength: Attaque physique (+1.5 dégâts/point)")
    table.insert(help_lines, "  dexterity: Esquive et précision (+1% esquive/point)")
    table.insert(help_lines, "  endurance: Santé et défense (+3 PV/point)")
    table.insert(help_lines, "  magic: Puissance magique (+1.2 dégâts magiques/point)")

    return table.concat(help_lines, "\n")
end

-- Fonction pour afficher une aide courte
function RPGCommands.show_short_help()
    return "Commandes disponibles: !help, !createplayer, !createmonster, !generatemonster, !generatequest, !roll, !stats, !fight, !describe, !ai, !listclasses. Tapez !help pour plus de détails."
end

-- Fonction pour afficher l'aide d'une catégorie spécifique
function RPGCommands.show_category_help(category_name)
    local category_commands = {}
    for _, cmd in ipairs(COMMAND_HELP) do
        if cmd.category:lower() == category_name:lower() then
            table.insert(category_commands, cmd)
        end
    end

    if #category_commands == 0 then
        local available_categories = {}
        for _, cmd in ipairs(COMMAND_HELP) do
            available_categories[cmd.category] = true
        end
        local cats = {}
        for cat, _ in pairs(available_categories) do table.insert(cats, cat) end
        return "Catégorie non trouvée. Catégories disponibles: " .. table.concat(cats, ", ")
    end

    local help_lines = {
        "📜 AIDE - " .. category_name:upper() .. " 📜",
        "================================"
    }

    for _, cmd in ipairs(category_commands) do
        table.insert(help_lines, "  " .. cmd.syntax)
        table.insert(help_lines, "    " .. cmd.description)
        table.insert(help_lines, "    Exemple: " .. cmd.example)
        table.insert(help_lines, "")  -- Ligne vide
    end

    return table.concat(help_lines, "\n")
end

-- Fonction principale d'exécution des commandes
function RPGCommands.execute_command(command_str, context)
    local parts = {}
    for word in command_str:gmatch("%S+") do table.insert(parts, word) end
    if #parts == 0 then return RPGCommands.show_short_help() end

    local cmd = parts[1]:lower()

    -- Commande HELP
    if cmd == "help" or cmd == "aide" then
        if #parts > 1 then
            return RPGCommands.show_category_help(parts[2])
        else
            return RPGCommands.show_help()
        end

    -- Commande CREATEPLAYER
    elseif cmd == "createplayer" then
        if #parts < 9 then
            for _, c in ipairs(COMMAND_HELP) do
                if c.command == "!createplayer" then
                    return "Usage: " .. c.syntax .. ". " .. c.description .. " Exemple: " .. c.example
                end
            end
        end
        -- ... (le reste de ton code existant pour createplayer)

    -- Autres commandes...
    else
        return "Commande inconnue. " .. RPGCommands.show_short_help()
    end
end

return RPGCommands

