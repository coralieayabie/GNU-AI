local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local Combat = require("rpg.combat")

local RPGCommands = {}

function RPGCommands.execute_command(command_str, context)
    local parts = {}
    for word in command_str:gmatch("%S+") do table.insert(parts, word) end
    if #parts == 0 then return "Erreur: commande vide" end

    local cmd = parts[1]:lower()

    -- Commandes de base
    if cmd == "help" or cmd == "aide" then
        return RPGCommands.show_help()

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

    elseif cmd == "createmonster" then
        if #parts < 4 then
            return "Usage: createmonster <nom> <classe> <niveau>"
        end
        local name, class_name, level = parts[2], parts[3], tonumber(parts[4])
        local monster = Monster.create(name, class_name, level)
        context.monsters[name] = monster
        return string.format("✅ Monstre créé: %s (%s, Lvl %d)", name, class_name, level)

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

    elseif cmd == "generatequest" then
        if not context.ai_quests then return "AI désactivée" end
        local level = tonumber(parts[2]) or 5
        local player_name = parts[3]
        local quest = context.ai_quests:generate(level, player_name, context.characters[player_name] and context.characters[player_name].class)
        return string.format("📜 Quête: %s\nDescription: %s\nRécompense: %d XP + %d Or",
            quest.title, quest.description, quest.reward.xp, quest.reward.gold)

    elseif cmd == "roll" then
        local num_dice = tonumber(parts[2]) or 1
        return "🎲 " .. Dice.roll_and_format(num_dice)

    elseif cmd == "listclasses" then
        return "Classes disponibles:\n" ..
               "Personnages: " .. table.concat(RPGClasses.get_available_character_classes(), ", ") .. "\n" ..
               "Monstres: " .. table.concat(RPGClasses.get_available_monster_classes(), ", ")

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

    elseif cmd == "fight" then
        if #parts < 3 then return "Usage: fight <player> <monster>" end
        local player_name, monster_name = parts[2], parts[3]
        if not context.characters[player_name] then return "Joueur non trouvé" end
        if not context.monsters[monster_name] then return "Monstre non trouvé" end
        local combat = Combat.execute_full_combat(context.characters[player_name], context.monsters[monster_name])
        Combat.display_combat_summary(combat)
        return "Combat terminé!"

    elseif cmd == "describe" and #parts >= 2 then
        if not context.ai then return "AI désactivée" end
        return context.ai:get_response("Décris '" .. parts[2] .. "' pour un RPG fantasy, en 2 phrases max.")

    else
        return "Commande inconnue. Tapez 'help' pour l'aide."
    end
end

function RPGCommands.show_help()
    return [[
📜 COMMANDES RPG DISPONIBLES:
!createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>
!createmonster <nom> <classe> <niveau>
!generatemonster <niveau> [classe] - Génère un monstre aléatoire
!generatequest <niveau> [joueur] - Génère une quête
!roll <nombre> - Lance des dés
!stats <player/monster> <nom> - Affiche les statistiques
!fight <joueur> <monstre> - Lance un combat
!describe <entité> - Décrit une entité
!listclasses - Liste les classes disponibles
!help - Affiche cette aide
]]
end

return RPGCommands

