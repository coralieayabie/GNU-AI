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
    -- Vérification de base
    if command_str == nil then
        return "Erreur: commande vide ou invalide"
    end
    
    -- Conversion sécurisée en chaîne
    if type(command_str) ~= "string" then
        command_str = tostring(command_str)
    end
    
    
    -- Analyse sécurisée des parties
    local parts = {}
    for part in command_str:gmatch("%S+") do
        table.insert(parts, part)
    end
    
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
        return "👥 Classes: " .. char_classes .. " | 👹 Monstres: " .. monster_classes
    
    elseif cmd == "stats" then
        if #parts < 3 then
            return "Usage: stats <type> <nom> (type: player/monster)"
        end
        local type = parts[2]:lower()
        local name = parts[3]
        
        if type == "player" and context.characters[name] then
            local char = context.characters[name]
            return string.format("👤 %s (Lvl %d %s): 💪%dHP 🧠%dINT 💪%dSTR 🏃%dDEX 🛡️%dEND ⚡%dMAG | 🎒%d💰 %d🥤",
                            char.name, char.level, char.class, char.health, 
                            char.attributes.intelligence, char.attributes.strength, 
                            char.attributes.dexterity, char.attributes.endurance, 
                            char.attributes.magic, char.inventory.gold, char.inventory.potions)
        elseif type == "monster" and context.monsters[name] then
            local mon = context.monsters[name]
            return string.format("👹 %s (Lvl %d %s): 💪%dHP ⚔️%dDMG 🛡️%dARM",
                            mon.name, mon.level, mon.class, mon.health, mon.damage, mon.armor)
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
        
        -- Créer un résumé compact pour IRC
        local result = combat.monster.health <= 0 and "🎉 VICTOIRE" or "☠️ DÉFAITE"
        local summary = string.format("⚔️ %s: %s en %d tours | 💪%s: %d/%dHP | 👹%s: %d/%dHP | 🎮 %s",
                                    result, 
                                    combat.player.name, combat.turn_count,
                                    combat.player.name, combat.player.health, combat.player.health_max,
                                    combat.monster.name, combat.monster.health, combat.monster.health or 100,
                                    result)
        
        return summary
    
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

-- Fonction pour afficher l'aide (version compacte pour IRC)
function RPGCommands.show_help()
    local help_text = {
        "AIDE RPG GNU-AI:",
        "📋 COMMANDES: help, createplayer, createmonster, roll, listclasses, stats, fight, use, heal",
        "👥 CLASSES: " .. table.concat(RPGClasses.get_available_character_classes(), ", ") .. " | Monstres: " .. table.concat(RPGClasses.get_available_monster_classes(), ", "),
        "🎮 EXEMPLE: !createplayer Gandalf mage 10 30 15 20 20 25",
        "📊 STATS: !stats player Gandalf",
        "⚔️ COMBAT: !fight Gandalf Balrog",
        "🎲 DÉS: !roll 3",
        "💬 Plus d'aide: https://github.com/coralieayabie/GNU-AI"
    }
    return table.concat(help_text, " | ")
end

-- Fonction pour obtenir la liste des commandes
function RPGCommands.get_available_commands()
    return commands
end

return RPGCommands