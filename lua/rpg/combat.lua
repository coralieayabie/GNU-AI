-- combat.lua - Système de combat avancé pour GNU-AI RPG
-- Avec jets de dés, règles de combat, et gestion des tours

local Dice = require("rpg.dice")
local Character = require("rpg.character")

local Combat = {}

-- Constantes de combat
local CRITICAL_HIT_CHANCE = 10  -- 10% de chance de coup critique
local CRITICAL_MULTIPLIER = 2   -- Multiplicateur de dégâts pour les coups critiques
local DODGE_CHANCE_BASE = 15     -- Chance de base d'esquive
local BLOCK_CHANCE_BASE = 20     -- Chance de base de bloquer

-- Crée une nouvelle session de combat
function Combat.create_combat_session(player, monster)
    return {
        player = player,
        monster = monster,
        current_turn = "player",  -- "player" ou "monster"
        turn_count = 0,
        log = {},
        is_active = true
    }
end

-- Ajoute une entrée au journal de combat
local function add_combat_log(combat, message)
    table.insert(combat.log, message)
end

-- Calcule les dégâts infligés
local function calculate_damage(attacker, defender, is_player_attacking)
    local base_damage
    local attack_skill
    local defense_skill
    
    if is_player_attacking then
        -- Joueur attaque le monstre
        base_damage = Character.calculate_weapon_damage(attacker)
        attack_skill = attacker.skills.attack
        defense_skill = defender.armor or 0
    else
        -- Monstre attaque le joueur
        base_damage = defender.damage or 10
        attack_skill = defender.damage or 10
        defense_skill = Character.calculate_armor_defense(defender)
    end
    
    -- Jet de dés pour les dégâts
    local dice_roll = Dice.roll_d6()
    
    -- Calculer les dégâts bruts
    local raw_damage = base_damage + math.floor(attack_skill / 2) + dice_roll
    
    -- Appliquer la défense
    local defense_reduction = math.floor(defense_skill / 3)
    local final_damage = math.max(1, raw_damage - defense_reduction)
    
    return final_damage, dice_roll, raw_damage, defense_reduction
end

-- Vérifie si une attaque est esquivée
local function check_dodge(defender)
    local dodge_chance = DODGE_CHANCE_BASE
    
    if defender.skills and defender.skills.stealth then
        dodge_chance = dodge_chance + defender.skills.stealth
    elseif defender.attributes and defender.attributes.dexterity then
        dodge_chance = dodge_chance + math.floor(defender.attributes.dexterity / 2)
    end
    
    -- Jet de dés pour l'esquive (1-100)
    local roll = math.random(1, 100)
    return roll <= dodge_chance
end

-- Vérifie si une attaque est bloquée
local function check_block(defender)
    local block_chance = BLOCK_CHANCE_BASE
    
    if defender.skills and defender.skills.defense then
        block_chance = block_chance + defender.skills.defense
    elseif defender.attributes and defender.attributes.endurance then
        block_chance = block_chance + math.floor(defender.attributes.endurance / 3)
    end
    
    -- Jet de dés pour le blocage (1-100)
    local roll = math.random(1, 100)
    return roll <= block_chance
end

-- Vérifie si c'est un coup critique
local function check_critical_hit(attacker)
    local critical_chance = CRITICAL_HIT_CHANCE
    
    if attacker.skills and attacker.skills.perception then
        critical_chance = critical_chance + math.floor(attacker.skills.perception / 2)
    end
    
    -- Jet de dés pour le coup critique (1-100)
    local roll = math.random(1, 100)
    return roll <= critical_chance
end

-- Exécute une attaque
local function perform_attack(combat, attacker, defender, is_player_attacking)
    -- Vérifier l'esquive
    if check_dodge(defender) then
        local dodge_msg = is_player_attacking 
            and defender.name .. " esquive l'attaque!"
            or combat.player.name .. " esquive l'attaque!"
        add_combat_log(combat, "⚡ " .. dodge_msg)
        return 0, "esquivé"
    end
    
    -- Vérifier le blocage
    if check_block(defender) then
        local block_msg = is_player_attacking 
            and defender.name .. " bloque l'attaque! (Dégâts réduits)"
            or combat.player.name .. " bloque l'attaque! (Dégâts réduits)"
        add_combat_log(combat, "🛡️ " .. block_msg)
        
        -- Dégâts réduits de 70% en cas de blocage
        local damage, dice_roll, raw_damage, defense_reduction = calculate_damage(attacker, defender, is_player_attacking)
        damage = math.floor(damage * 0.3)
        
        if is_player_attacking then
            defender.health = math.max(0, defender.health - damage)
        else
            combat.player.health = math.max(0, combat.player.health - damage)
        end
        
        local damage_msg = is_player_attacking 
            and string.format("💥 %s inflige %d dégâts (blocage) à %s! (Jet: %d)", 
                     combat.player.name, damage, defender.name, dice_roll)
            or string.format("💥 %s inflige %d dégâts (blocage) à %s! (Jet: %d)", 
                     defender.name, damage, combat.player.name, dice_roll)
        add_combat_log(combat, damage_msg)
        
        return damage, "bloqué"
    end
    
    -- Vérifier le coup critique
    local is_critical = check_critical_hit(is_player_attacking and combat.player or defender)
    
    -- Calculer les dégâts
    local damage, dice_roll, raw_damage, defense_reduction = calculate_damage(attacker, defender, is_player_attacking)
    
    if is_critical then
        damage = math.floor(damage * CRITICAL_MULTIPLIER)
        add_combat_log(combat, "🎯 COUP CRITIQUE! Dégâts doublés!")
        
        if is_player_attacking then
            combat.player.combat_stats.critical_hits = combat.player.combat_stats.critical_hits + 1
        end
    end
    
    -- Appliquer les dégâts
    if is_player_attacking then
        defender.health = math.max(0, defender.health - damage)
        combat.player.combat_stats.damage_dealt = combat.player.combat_stats.damage_dealt + damage
        defender.damage_taken = (defender.damage_taken or 0) + damage
    else
        combat.player.health = math.max(0, combat.player.health - damage)
        combat.player.combat_stats.damage_taken = combat.player.combat_stats.damage_taken + damage
    end
    
    -- Message de dégâts
    local damage_msg = is_player_attacking 
        and string.format("💥 %s inflige %d dégâts à %s! (Jet: %d, Brut: %d, Défense: %d)", 
                 combat.player.name, damage, defender.name, dice_roll, raw_damage, defense_reduction)
        or string.format("💥 %s inflige %d dégâts à %s! (Jet: %d)", 
                 defender.name, damage, combat.player.name, dice_roll)
    add_combat_log(combat, damage_msg)
    
    return damage, "normal"
end

-- Exécute un tour de combat
function Combat.execute_turn(combat)
    if not combat.is_active then
        return false, "Le combat est déjà terminé"
    end
    
    combat.turn_count = combat.turn_count + 1
    add_combat_log(combat, string.format("=== TOUR %d ===", combat.turn_count))
    
    if combat.current_turn == "player" then
        -- Tour du joueur
        add_combat_log(combat, "🔹 Tour de " .. combat.player.name)
        
        -- Le joueur attaque
        local damage, result = perform_attack(combat, combat.player, combat.monster, true)
        
        -- Vérifier si le monstre est vaincu
        if combat.monster.health <= 0 then
            combat.monster.health = 0
            combat.is_active = false
            
            -- Ajouter l'expérience au joueur
            local exp_gained = combat.monster.level * 20
            local old_level = combat.player.level
            Character.add_experience(combat.player, exp_gained)
            
            -- Mettre à jour les statistiques de combat
            combat.player.combat_stats.wins = combat.player.combat_stats.wins + 1
            combat.player.combat_stats.monsters_defeated = combat.player.combat_stats.monsters_defeated + 1
            
            -- Ajouter des récompenses
            local gold_reward = combat.monster.level * 15
            local potion_chance = math.random(1, 100)
            
            Character.add_to_inventory(combat.player, "gold", gold_reward)
            if potion_chance <= 30 then  -- 30% de chance de drop une potion
                Character.add_to_inventory(combat.player, "potion", 1)
                add_combat_log(combat, "🎁 Vous avez reçu une potion!")
            end
            
            local victory_msg = string.format("🎉 VICTOIRE! %s a vaincu %s!", 
                                            combat.player.name, combat.monster.name)
            add_combat_log(combat, victory_msg)
            add_combat_log(combat, string.format("💰 Récompenses: %d pièces d'or + %d EXP", 
                                            gold_reward, exp_gained))
            
            if combat.player.level > old_level then
                add_combat_log(combat, string.format("📈 NIVEAU AUGMENTÉ! %s est maintenant niveau %d!", 
                                                combat.player.name, combat.player.level))
            end
            
            return true, "victoire"
        end
        
        -- Passer au tour du monstre
        combat.current_turn = "monster"
        
    else
        -- Tour du monstre
        add_combat_log(combat, "🔴 Tour de " .. combat.monster.name)
        
        -- Le monstre attaque
        local damage, result = perform_attack(combat, combat.monster, combat.player, false)
        
        -- Vérifier si le joueur est vaincu
        if combat.player.health <= 0 then
            combat.player.health = 0
            combat.is_active = false
            
            -- Mettre à jour les statistiques de combat
            combat.player.combat_stats.losses = combat.player.combat_stats.losses + 1
            
            add_combat_log(combat, string.format("☠️ DÉFAITE! %s a été vaincu par %s!", 
                                            combat.player.name, combat.monster.name))
            
            return true, "défaite"
        end
        
        -- Passer au tour du joueur
        combat.current_turn = "player"
    end
    
    return true, "en_cours"
end

-- Exécute un combat complet jusqu'à la fin
function Combat.execute_full_combat(player, monster)
    local combat = Combat.create_combat_session(player, monster)
    
    add_combat_log(combat, string.format("🔥 COMBAT COMMENCÉ: %s (Lvl %d) vs %s (Lvl %d)", 
                                    player.name, player.level, monster.name, monster.level))
    add_combat_log(combat, string.format("📊 Stats initiales - %s: %d/%d HP | %s: %d/%d HP", 
                                    player.name, player.health, player.health_max,
                                    monster.name, monster.health, monster.health or 100))
    
    -- Boucle de combat
    while combat.is_active do
        local success, status = Combat.execute_turn(combat)
        
        if not success then
            add_combat_log(combat, "❌ Erreur lors du combat: " .. status)
            break
        end
        
        -- Petite pause pour le mode interactif (peut être retiré)
        -- os.execute("sleep 0.5")
    end
    
    return combat
end

-- Affiche le journal de combat
function Combat.display_combat_log(combat)
    print("╔════════════════════════════════════════════════════════════╗")
    print("║                  JOURNAL DE COMBAT                    ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    for i, entry in ipairs(combat.log) do
        print(entry)
    end
    
    print("╔════════════════════════════════════════════════════════════╗")
    print("║                    FIN DU COMBAT                      ║")
    print("╚════════════════════════════════════════════════════════════╝")
end

-- Affiche un résumé du combat
function Combat.display_combat_summary(combat)
    print("\n╔════════════════════════════════════════════════════════════╗")
    print("║                  RÉSUMÉ DU COMBAT                     ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    local result = combat.monster.health <= 0 and "VICTOIRE" or "DÉFAITE"
    local result_color = combat.monster.health <= 0 and "🎉" or "☠️"
    
    print(string.format("Résultat: %s %s", result_color, result))
    print(string.format("Durée: %d tours", combat.turn_count))
    print(string.format("Dégâts infligés par %s: %d", combat.player.name, combat.player.combat_stats.damage_dealt))
    print(string.format("Dégâts reçus par %s: %d", combat.player.name, combat.player.combat_stats.damage_taken))
    print(string.format("Coups critiques: %d", combat.player.combat_stats.critical_hits))
    
    if combat.monster.health <= 0 then
        print(string.format("Expérience gagnée: %d EXP", combat.player.experience))
        print(string.format("Or gagné: %d pièces", combat.player.inventory.gold))
    end
    
    print(string.format("Santé finale - %s: %d/%d", combat.player.name, combat.player.health, combat.player.health_max))
    print(string.format("Santé finale - %s: %d/%d", combat.monster.name, combat.monster.health, combat.monster.health or 100))
    
    print("╔════════════════════════════════════════════════════════════╗")
    print("║              STATISTIQUES MISES À JOUR                ║")
    print("╚════════════════════════════════════════════════════════════╝")
end

return Combat
>>>>>>> REPLACE