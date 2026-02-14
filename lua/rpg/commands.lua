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
        
        -- Vérification que le niveau est valide
        if not level or level < 1 or level > 100 then
            return "❌ Erreur: Le niveau doit être un nombre entre 1 et 100"
        end
        
        local attrs = {
            intelligence = tonumber(parts[5]),
            strength = tonumber(parts[6]),
            dexterity = tonumber(parts[7]),
            endurance = tonumber(parts[8]),
            magic = tonumber(parts[9])
        }
        
        -- Vérification que tous les attributs sont des nombres valides
        for attr_name, value in pairs(attrs) do
            if not value or value < 0 or value > 100 then
                return string.format("❌ Erreur: L'attribut %s doit être un nombre entre 0 et 100", attr_name)
            end
        end
        
        -- Vérification préalable des points
        local total_points = (attrs.intelligence or 0) + (attrs.strength or 0) + (attrs.dexterity or 0) + (attrs.endurance or 0) + (attrs.magic or 0)
        if total_points > 100 then
            return string.format("❌ Erreur: Trop de points! Vous avez utilisé %d/100. " .. 
                               "Réduisez certains attributs. Actuel: Int:%d Str:%d Dex:%d End:%d Mag:%d",
                               total_points, attrs.intelligence, attrs.strength, attrs.dexterity, attrs.endurance, attrs.magic)
        end
        
        -- Création du personnage
        local success, character_or_error = pcall(Character.create_with_attributes, name, class_name, level, attrs)
        if not success then
            return "❌ " .. character_or_error
        end
        
        context.characters[name] = character_or_error
        return "✅ Personnage créé: " .. name .. " (" .. class_name .. " niveau " .. level .. ") | 💪" .. character_or_error.health .. "HP"
    
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
        
        -- Créer un ID unique pour le combat
        local combat_id = "combat_" .. os.time()
        
        -- Créer un combat avec support IRC pour les logs en temps réel
        local combat = Combat.create_combat_session(player, combat_monster, 1, 0, context.irc_bot)
        
        -- Stocker le combat dans le contexte pour un contrôle ultérieur
        if not context.combats then
            context.combats = {}
        end
        context.combats[combat_id] = combat
        
        -- Annoncer le début du combat sur IRC
        if context.irc_bot then
            context.irc_bot:send_combat_log(string.format("🔥 COMBAT COMMENCÉ: %s (Lvl %d) vs %s (Lvl %d) [ID: %s]", 
                player.name, player.level, monster.name, monster.level, combat_id))
        end
        
        -- Exécuter le combat tour par tour
        while combat.is_active do
            Combat.execute_turn(combat)
        end
        
        -- Supprimer le combat du contexte après la fin
        context.combats[combat_id] = nil
        
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
    
    elseif cmd == "combathelp" or cmd == "fighthelp" then
        return RPGCommands.show_combat_help()
    elseif cmd == "setdice" then
        if #parts < 3 then
            return "Usage: setdice <combat_id> <nombre> - Définir le nombre de dés (1-5)"
        end
        local combat_id = parts[2]
        local num_dice = tonumber(parts[3]) or 1
        if num_dice < 1 or num_dice > 5 then
            return "❌ Erreur: Le nombre de dés doit être entre 1 et 5"
        end
        if not context.combats then
            context.combats = {}
        end
        if not context.combats[combat_id] then
            return "❌ Erreur: Combat non trouvé: " .. combat_id
        end
        Combat.set_num_dice(context.combats[combat_id], num_dice)
        return "✅ Nombre de dés défini à " .. num_dice
    elseif cmd == "listcombats" then
        if not context.combats or next(context.combats) == nil then
            return "Aucun combat actif"
        end
        local combat_list = {}
        for combat_id, combat in pairs(context.combats) do
            table.insert(combat_list, string.format("%s: %s vs %s (Tour %d)", 
                combat_id, combat.player.name, combat.monster.name, combat.turn_count))
        end
        return "Combats actifs: " .. table.concat(combat_list, ", ")
    elseif cmd == "setaction" then
        if #parts < 4 then
            return "Usage: setaction <combat_id> <joueur/monstre> <action> - Définir l'action (attaque/défense/esquive/magie)"
        end
        local combat_id = parts[2]
        local target = parts[3]:lower()
        local action = parts[4]:lower()
        
        if not context.combats or not context.combats[combat_id] then
            return "❌ Erreur: Combat non trouvé: " .. combat_id
        end
        
        if target == "joueur" or target == "player" then
            Combat.set_player_action(context.combats[combat_id], action)
        elseif target == "monstre" or target == "monster" then
            Combat.set_monster_action(context.combats[combat_id], action)
        else
            return "❌ Erreur: Cible invalide. Utilisez 'joueur' ou 'monstre'"
        end
        
        return "✅ Action définie: " .. target .. " -> " .. action
    else
        return "Commande inconnue: " .. cmd .. ". Tapez 'help' pour l'aide."
    end
end

-- Fonction pour afficher l'aide (version compacte pour IRC)
function RPGCommands.show_help()
    local help_text = {
        "AIDE RPG GNU-AI:",
        "📋 COMMANDES: help, combathelp, createplayer, createmonster, roll, listclasses, stats, fight, use, heal, listcombats, setdice, setaction",
        "👥 CLASSES: " .. table.concat(RPGClasses.get_available_character_classes(), ", ") .. " | Monstres: " .. table.concat(RPGClasses.get_available_monster_classes(), ", "),
        "🎮 EXEMPLE: !createplayer Gandalf mage 10 30 15 20 20 25",
        "📊 STATS: !stats player Gandalf",
        "⚔️ COMBAT: !fight Gandalf Balrog",
        "🎲 DÉS: !roll 3",
        "💡 AIDE COMBAT: !combathelp ou !fighthelp",
        "💬 Plus d'aide: https://github.com/coralieayabie/GNU-AI"
    }
    return table.concat(help_text, " | ")
end

-- Fonction pour afficher l'aide spécifique au combat
function RPGCommands.show_combat_help()
    local combat_help = {
        "🎮 AIDE SYSTÈME DE COMBAT RPG AVANCÉ:",
        "⚔️ COMMANDE: !fight <joueur> <monstre>",
        "📊 MÉCANIQUES: Tour par tour avec choix d'actions",
        "🎲 JETS: 1-5 dés avec modificateurs de compétences",
        "💥 DÉGÂTS: Calculés avec attaque/défense/armure",
        "🛡️ ESQUIVE: Chance basée sur dextérité/furtivité",
        "🔥 BLOCAGE: Réduit dégâts de 70% (basé sur endurance)",
        "🎯 CRITIQUE: Dégâts doublés (10% + bonus perception)",
        "✨ MAGIE: Sorts aléatoires pour chaque classe",
        "🏆 RÉCOMPENSES: EXP + Or + Potions (30% chance)",
        "📈 EXP: Niveau_monstre × 20 par victoire",
        "💰 OR: Niveau_monstre × 15 par victoire",
        "💬 EXEMPLE: !fight Aragorn Balrog",
        "🎮 CONTRÔLE: !setdice <id> <1-5>, !setaction <id> <cible> <action>"
    }
    return table.concat(combat_help, " | ")
end

-- Fonction pour obtenir la liste des commandes
function RPGCommands.get_available_commands()
    return commands
end

return RPGCommands