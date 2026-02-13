-- commands.lua - Système de commandes unifié pour l'agent RPG
-- Permet d'interagir avec le système RPG via des commandes simples

local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local Combat = require("rpg.combat")

local RPGCommands = {}

-- Liste des commandes disponibles
local commands = {
    help = "Affiche l'aide",
    createplayer = "Crée un nouveau personnage",
    createmoster = "Crée un nouveau monstre",
    roll = "Lance des dés",
    listclasses = "Liste les classes disponibles",
    stats = "Affiche les statistiques détaillées",
    fight = "Lance un combat contre un monstre",
    use = "Utilise un objet (potion, arme, armure)",
    equip = "Équipe un objet",
    heal = "Restaure la santé"
}

-- Fonction pour analyser et exécuter une commande
function RPGCommands.execute_command(command_str, context)
    local parts = {}
    for part in command_str:gmatch("%S+") do
        table.insert(parts, part)
    end
end

function faultyFunction()
    local a = nil
    print(a.value)  -- This will cause an error
end

function safeFunction()
    local success, err = pcall(faultyFunction)
    if not success then
        print("Error:", err)
        print(debug.traceback())
    end
end

function safeFunction()

    
    if #parts == 0 then
        return "Erreur: commande vide"
    end
    
    local cmd = parts[1]:lower()
    
    if cmd == "help" or cmd == "aide" then
        return RPGCommands.show_help()
    
    elseif cmd == "createplayer" then
        if #parts < 5 then
            return "Usage: createplayer <nom> <classe> <niveau> <intelligence> <force> <dexterité> <endurance> <magie>"
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
        return "Personnage créé: " .. name .. " (" .. class_name .. ")"
    
    elseif cmd == "createmonster" then
        if #parts < 4 then
            return "Usage: createmonster <nom> <classe> <niveau>"
        end
        local name, class_name, level = parts[2], parts[3], tonumber(parts[4])
        local monster, err = Monster.create(name, class_name, level)
        if monster then
            context.monsters[name] = monster
            return "Monstre créé: " .. name .. " (" .. class_name .. " niveau " .. level .. ")"
        else
            return "Erreur: " .. err
        end
    
    elseif cmd == "roll" then
        local num_dice = tonumber(parts[2]) or 1
        return "Lancer de dés: " .. Dice.roll_and_format(num_dice)
    
    elseif cmd == "listclasses" then
        local char_classes = table.concat(RPGClasses.get_available_character_classes(), ", ")
        local monster_classes = table.concat(RPGClasses.get_available_monster_classes(), ", ")
        return "Classes de personnages: " .. char_classes .. "\nClasses de monstres: " .. monster_classes
    
    elseif cmd == "stats" then
        if #parts < 3 then
            return "Usage: stats <type> <nom> (type: player/monster)"
        end
        local type = parts[2]:lower()
        local name = parts[3]
        
        if type == "player" and context.characters[name] then
            return Character.display_detailed_stats(context.characters[name])
        elseif type == "monster" and context.monsters[name] then
            return Monster.display_stats(context.monsters[name])
        else
            return "Entité non trouvée: " .. name
        end
    
    elseif cmd == "fight" then
        if #parts < 3 then
            return "Usage: fight <player> <monster> - Lance un combat entre un joueur et un monstre"
        end
        local player_name = parts[2]
        local monster_name = parts[3]
        
        if not context.characters[player_name] then
            return "Joueur non trouvé: " .. player_name
        end
        
        if not context.monsters[monster_name] then
            return "Monstre non trouvé: " .. monster_name
        end
        
        local player = context.characters[player_name]
        local monster = context.monsters[monster_name]
        
        -- Créer une copie du monstre pour ne pas modifier l'original
        local combat_monster = {
            name = monster.name,
            class = monster.class,
            level = monster.level,
            health = monster.health,
            damage = monster.damage,
            armor = monster.armor,
            attributes = monster.attributes,
            spells = monster.spells
        }
        
        -- Lancer le combat
        local combat = Combat.execute_full_combat(player, combat_monster)
        
        -- Afficher le journal de combat
        Combat.display_combat_log(combat)
        
        -- Afficher le résumé
        Combat.display_combat_summary(combat)
        
        return "Combat terminé! (voir journal ci-dessus)"
    
    elseif cmd == "use" then
        if #parts < 3 then
            return "Usage: use <type> <nom> - Types: potion, weapon <nom>, armor <nom>"
        end
        
        local item_type = parts[2]:lower()
        local item_name = table.concat(parts, " ", 3)
        
        if item_type == "potion" then
            local player_name = parts[3]
            if not player_name or not context.characters[player_name] then
                return "Usage: use potion <nom_joueur>"
            end
            
            local success, message = Character.use_potion(context.characters[player_name])
            return message
            
        elseif item_type == "weapon" then
            local player_name = parts[3]
            local weapon_name = table.concat(parts, " ", 4)
            if not player_name or not weapon_name or not context.characters[player_name] then
                return "Usage: use weapon <nom_joueur> <nom_arme>"
            end
            
            local success, message = Character.equip_weapon(context.characters[player_name], weapon_name)
            return message
            
        elseif item_type == "armor" then
            local player_name = parts[3]
            local armor_name = table.concat(parts, " ", 4)
            if not player_name or not armor_name or not context.characters[player_name] then
                return "Usage: use armor <nom_joueur> <nom_armure>"
            end
            
            local success, message = Character.equip_armor(context.characters[player_name], armor_name)
            return message
            
        else
            return "Type d'objet inconnu: " .. item_type
        end
    
    elseif cmd == "equip" then
        return "La commande 'equip' a été remplacée par 'use weapon' et 'use armor'"
    
    elseif cmd == "heal" then
        if #parts < 3 then
            return "Usage: heal <nom_joueur> <quantité>"
        end
        
        local player_name = parts[2]
        local amount = tonumber(parts[3]) or 10
        
        if not context.characters[player_name] then
            return "Joueur non trouvé: " .. player_name
        end
        
        local new_health = Character.heal(context.characters[player_name], amount)
        return string.format("❤️ %s a été soigné! Santé: %d/%d", 
                          player_name, new_health, context.characters[player_name].health_max)
    
    else
        return "Commande inconnue: " .. cmd .. ". Tapez 'help' pour l'aide."
    end
end

-- Fonction pour afficher l'aide
function RPGCommands.show_help()
    local help_text = {
        "###############################",
        "###  AIDE RPG GNU-AI AVANCE ###",
        "###############################",
        "",
        "- COMMANDES DE BASE:",
        "  help - Affiche cette aide",
        "  createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>",
        "  createmonster <nom> <classe> <niveau> - Crée un monstre",
        "  roll <nombre> - Lance des dés (max 10)",
        "  listclasses - Liste les classes disponibles",
        "",
        "- COMMANDES DE STATISTIQUES:",
        "  stats <player/monster> <nom> - Affiche les statistiques détaillées",
        "",
        "- COMMANDES DE COMBAT:",
        "  fight <joueur> <monstre> - Lance un combat épique!",
        "",
        " - COMMANDES D'INVENTAIRE:",
        "  use potion <joueur> - Utilise une potion de soin",
        "  use weapon <joueur> <arme> - Équipe une arme",
        "  use armor <joueur> <armure> - Équipe une armure",
        "  heal <joueur> <quantité> - Restaure la santé",
        "",
        "- SYSTEME DE CREATION (100 points max):",
        "  intelligence - Affecte la magie et la perception",
        "  strength - Affecte l'attaque physique",
        "  dexterity - Affecte l'esquive et la furtivité",
        "  endurance - Affecte la santé et la défense",
        "  magic - Affecte les sorts et la résistance magique",
        "",
        "- CLASSES DISPONIBLES:",
        "  Personnages: " .. table.concat(RPGClasses.get_available_character_classes(), ", "),
        "  Monstres: " .. table.concat(RPGClasses.get_available_monster_classes(), ", "),
        "",
        "- EXEMPLES:",
        "  createplayer Aragorn humain 5 25 25 20 20 10",
        "  createmonster Balrog vampire 10",
        "  fight Aragorn Balrog",
        "  use potion Aragorn",
        "  stats player Aragorn"
    }
    return table.concat(help_text, "\n")
end

-- Fonction pour obtenir la liste des commandes
function RPGCommands.get_available_commands()
    return commands
end

return RPGCommands
