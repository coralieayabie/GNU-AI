-- rpg/commands.lua - Version complète
local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local Combat = require("rpg.combat")

local RPGCommands = {}

-- Liste des commandes pour l'aide
local COMMAND_LIST = {
    {"!createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>",
     "Crée un personnage (100 pts max: int+str+dex+end+mag)"},
    {"!createmonster <nom> <classe> <niveau>",
     "Crée un monstre"},
    {"!generatemonster [niveau] [classe]",
     "Génère un monstre aléatoire via l'AI"},
    {"!generatequest [niveau] [joueur]",
     "Génère une quête aléatoire via l'AI"},
    {"!roll [nombre]",
     "Lance 1-10 dés (défaut: 1)"},
    {"!stats <player/monster> <nom>",
     "Affiche les statistiques"},
    {"!fight <joueur> <monstre>",
     "Lance un combat"},
    {"!describe <entité>",
     "Décrit une entité via l'AI"},
    {"!ai <question>",
     "Pose une question à l'AI"},
    {"!listclasses",
     "Liste les classes disponibles"},
    {"!help / !aide",
     "Affiche cette aide"}
}

function RPGCommands.show_help()
    local char_classes = table.concat(RPGClasses.get_available_character_classes(), ", ")
    local monster_classes = table.concat(RPGClasses.get_available_monster_classes(), ", ")

    local help = {
        "📜 COMMANDES RPG GNU-AI (v1.0) 📜",
        "================================",
        "🔹 COMMANDES DISPONIBLES:"
    }

    for _, cmd in ipairs(COMMAND_LIST) do
        table.insert(help, "  " .. cmd[1])
        table.insert(help, "    " .. cmd[2])
    end

    table.insert(help, "")
    table.insert(help, "🔹 CLASSES DISPONIBLES:")
    table.insert(help, "  Personnages: " .. char_classes)
    table.insert(help, "  Monstres: " .. monster_classes)

    table.insert(help, "")
    table.insert(help, "🔹 EXEMPLES:")
    table.insert(help, "  !createplayer Aragorn humain 5 20 20 15 15 10")
    table.insert(help, "  !generatemonster 8 loup_garou")
    table.insert(help, "  !fight Aragorn Balrog")

    return table.concat(help, "\n")
end

function RPGCommands.execute_command(command_str, context)
    local parts = {}
    for word in command_str:gmatch("%S+") do table.insert(parts, word) end
    if #parts == 0 then return "Erreur: commande vide" end

    local cmd = parts[1]:lower()

    -- Commande HELP
    if cmd == "help" or cmd == "aide" then
        return RPGCommands.show_help()

    -- Commande CREATEPLAYER
    elseif cmd == "createplayer" then
        if #parts < 9 then
            return "Usage: createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>"
        end
        local name, class_name, level = parts[2], parts[3], tonumber(parts[4])
        local attrs = {
            intelligence = tonumber(parts[5]),
            strength = tonumber(parts[6]),
            dexterity = tonumber(parts[7]),
            endurance = tonumber(parts[8]),
            magic = tonumber(parts[9])
        }
        local character = Character.create_with_attributes(name, class_name, level, attrs)
        context.characters[name] = character
        return string.format("✅ Personnage créé: %s (%s, Lvl %d)", name, class_name, level)

    -- Commande CREATEMONSTER
    elseif cmd == "createmonster" then
        if #parts < 4 then
            return "Usage: createmonster <nom> <classe> <niveau>"
        end
        local name, class_name, level = parts[2], parts[3], tonumber(parts[4])
        local monster = Monster.create(name, class_name, level)
        context.monsters[name] = monster
        return string.format("✅ Monstre créé: %s (%s, Lvl %d)", name, class_name, level)

    -- Commande GENERATEMONSTER
    elseif cmd == "generatemonster" then
        if not context.ai_monsters then return "AI désactivée" end
        local level = tonumber(parts[2]) or 5
        local monster_class = parts[3]
        local monster = monster_class
            and context.ai_monsters:generate_from_class(monster_class, level)
            or context.ai_monsters:generate_random(level)
        if not monster then return "Échec de génération" end
        context.monsters[monster.name] = monster
        return string.format("✨ %s (Lvl %d) créé! %s", monster.name, monster.level, monster.description)

    -- Commande GENERATEQUEST
    elseif cmd == "generatequest" then
        if not context.ai_quests then return "AI désactivée" end
        local level = tonumber(parts[2]) or 5
        local player_name = parts[3]
        local quest = context.ai_quests:generate(level, player_name, context.characters[player_name] and context.characters[player_name].class)
        return string.format("📜 Quête: %s\nDescription: %s\nRécompense: %d XP + %d Or",
            quest.title, quest.description, quest.reward.xp, quest.reward.gold)

    -- Commande ROLL
    elseif cmd == "roll" then
        local num_dice = tonumber(parts[2]) or 1
        return "🎲 " .. Dice.roll_and_format(num_dice)

    -- Commande LISTCLASSES
    elseif cmd == "listclasses" then
        local char_classes = table.concat(RPGClasses.get_available_character_classes(), ", ")
        local monster_classes = table.concat(RPGClasses.get_available_monster_classes(), ", ")
        return "Classes disponibles:\nPersonnages: " .. char_classes .. "\nMonstres: " .. monster_classes

    -- Commande STATS
    elseif cmd == "stats" then
        if #parts < 3 then return "Usage: stats <player/monster> <nom>" end
        local type, name = parts[2]:lower(), parts[3]
        if type == "player" and context.characters[name] then
            return Character.display_detailed_stats(context.characters[name])
        elseif type == "monster" and context.monsters[name] then
            return Monster.display_stats(context.monsters[name])
        else
            return "Entité non trouvée: " .. name
        end

    -- Commande FIGHT
    elseif cmd == "fight" then
        if #parts < 3 then return "Usage: fight <player> <monster>" end
        local player_name, monster_name = parts[2], parts[3]
        if not context.characters[player_name] then return "Joueur non trouvé" end
        if not context.monsters[monster_name] then return "Monstre non trouvé" end
        local combat = Combat.execute_full_combat(context.characters[player_name], context.monsters[monster_name])
        Combat.display_combat_summary(combat)
        return "Combat terminé!"

    -- Commande DESCRIBE
    elseif cmd == "describe" and #parts >= 2 then
        if not context.ai then return "AI désactivée" end
        return context.ai:get_response("Décris '" .. parts[2] .. "' pour un RPG fantasy, en 2 phrases max.")

    -- Commande inconnue
    else
        return "Commande inconnue. Tapez '!help' pour l'aide."
    end
end

return RPGCommands

