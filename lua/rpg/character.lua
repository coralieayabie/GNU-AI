-- character.lua - Système de personnages RPG avancé pour GNU-AI
-- Avec statistiques détaillées, inventaire, compétences et énergie

local RPGClasses = require("rpg.classes")
local Dice = require("rpg.dice")

local Character = {}
Character.__index = Character

-- Constantes
local MAX_CREATION_POINTS = 100
local DEFAULT_ENERGY = 50

function Character.new()
    return setmetatable({}, Character)
end

-- Crée un personnage avec des attributs personnalisés
-- points_distribution: table avec intelligence, strength, dexterity, endurance, magic
function Character.create_with_attributes(name, class_name, level, points_distribution)
    local character_class = RPGClasses.get_character_class(class_name)
    if not character_class then
        character_class = RPGClasses.get_character_class("humain")
    end
    
    -- Vérifier que la distribution de points ne dépasse pas 100
    local total_points = 0
    for _, value in pairs(points_distribution or {}) do
        total_points = total_points + (value or 0)
    end
    
    if total_points > MAX_CREATION_POINTS then
        error(string.format("❌ Erreur de création: Vous avez utilisé %d points, mais la limite est de %d points.\n", 
                          total_points, MAX_CREATION_POINTS) ..
              string.format("💡 Conseils: Réduisez certains attributs. Somme actuelle: %d (Int:%d + Str:%d + Dex:%d + End:%d + Mag:%d)\n",
                          total_points, 
                          points_distribution.intelligence or 0,
                          points_distribution.strength or 0,
                          points_distribution.dexterity or 0,
                          points_distribution.endurance or 0,
                          points_distribution.magic or 0) ..
              "🎯 Suggestions pour 100 points:\n" ..
              "  • Mage: Int:30 Str:10 Dex:15 End:20 Mag:25\n" ..
              "  • Guerrier: Int:10 Str:30 Dex:20 End:25 Mag:15\n" ..
              "  • Voleur: Int:15 Str:20 Dex:25 End:20 Mag:20\n" ..
              "  • Équilibré: Int:20 Str:20 Dex:20 End:20 Mag:20")
    end
    
    -- Initialiser les attributs de base d'abord avec vérification de nil
    local base_attributes = character_class.base_attributes or {
        intelligence = 5,
        strength = 5,
        dexterity = 5,
        endurance = 5,
        magic = 5
    }
    local base_energy = character_class.base_energy or character_class.base_energy_max or 100
    
    -- S'assurer que points_distribution existe
    points_distribution = points_distribution or {}
    
    -- Créer les attributs d'abord
    local attrs = {
        intelligence = points_distribution.intelligence or base_attributes.intelligence,
        strength = points_distribution.strength or base_attributes.strength,
        dexterity = points_distribution.dexterity or base_attributes.dexterity,
        endurance = points_distribution.endurance or base_attributes.endurance,
        magic = points_distribution.magic or base_attributes.magic
    }
    
    -- Créer le personnage avec toutes les valeurs par défaut
    local character = {
        name = name,
        class = character_class.name,
        level = level or 1,
        experience = 0,
        experience_to_next_level = 100,
        attributes = attrs,
        energy = DEFAULT_ENERGY,
        energy_max = DEFAULT_ENERGY,
        health = math.floor(base_energy / 10),
        health_max = math.floor(base_energy / 10),
        skills = {}
    }
    
    -- Calculer les compétences après la création du personnage
    character.skills.attack = math.floor((character.attributes.strength + character.attributes.dexterity) / 2)
    character.skills.defense = math.floor(character.attributes.endurance / 2)
    character.skills.magic_attack = math.floor((character.attributes.intelligence + character.attributes.magic) / 2)
    character.skills.magic_defense = math.floor(character.attributes.magic)
    character.skills.stealth = math.floor(character.attributes.dexterity / 2)
    character.skills.perception = math.floor(character.attributes.intelligence / 2)
    
    -- Ajouter les autres propriétés au personnage
    character.inventory = {
        gold = 100,
        items = {},
        weapons = {},
        armor = nil,
        potions = 0
    }
    
    character.equipment = {
        weapon = "Poings",
        armor = "Vêtements",
        accessory = "Aucun"
    }
    
    character.spells = character_class.base_spells or {}
    character.abilities = {"Attaque basique", "Défense", "Esquive"}
    
    character.combat_stats = {
        wins = 0,
        losses = 0,
        monsters_defeated = 0,
        damage_dealt = 0,
        damage_taken = 0,
        critical_hits = 0
    }
    
    -- Calculer les points restants pour la création
    character.creation_points_remaining = MAX_CREATION_POINTS - total_points
    
    return character
end

-- Crée un personnage par défaut
function Character.create_default()
    return Character.create_with_attributes("Héros", "humain", 1, {
        intelligence = 20,
        strength = 20,
        dexterity = 20,
        endurance = 20,
        magic = 20
    })
end

-- Affiche les statistiques détaillées d'un personnage
function Character.display_detailed_stats(character)
    local stats = {
        "╔════════════════════════════════════════════════════════════╗",
        "║           STATISTIQUES DÉTAILLÉES - " .. string.upper(character.name) .. "          ║",
        "╚════════════════════════════════════════════════════════════╝",
        "",
        "📊 INFORMATIONS GÉNÉRALES:",
        "  Nom: " .. character.name .. " (" .. character.class .. ")",
        "  Niveau: " .. character.level .. " (Exp: " .. character.experience .. "/" .. character.experience_to_next_level .. ")",
        "  Santé: " .. character.health .. "/" .. character.health_max,
        "  Énergie: " .. character.energy .. "/" .. character.energy_max,
        "",
        "💪 ATTRIBUTS DE BASE (" .. (MAX_CREATION_POINTS - character.creation_points_remaining) .. "/" .. MAX_CREATION_POINTS .. " points utilisés):",
        "  Intelligence: " .. character.attributes.intelligence .. " (Affecte: magie, perception)",
        "  Force: " .. character.attributes.strength .. " (Affecte: attaque physique)",
        "  Dextérité: " .. character.attributes.dexterity .. " (Affecte: esquive, stealth)",
        "  Endurance: " .. character.attributes.endurance .. " (Affecte: santé, défense)",
        "  Magie: " .. character.attributes.magic .. " (Affecte: sorts, résistance magique)",
        "  Points restants: " .. character.creation_points_remaining,
        "",
        "⚔️ COMPÉTENCES:",
        "  Attaque: " .. character.skills.attack,
        "  Défense: " .. character.skills.defense,
        "  Attaque magique: " .. character.skills.magic_attack,
        "  Défense magique: " .. character.skills.magic_defense,
        "  Furtivité: " .. character.skills.stealth,
        "  Perception: " .. character.skills.perception,
        "",
        "🎒 INVENTAIRE:",
        "  Or: " .. character.inventory.gold .. " pièces",
        "  Potions: " .. character.inventory.potions,
        "  Armes: " .. (#character.inventory.weapons > 0 and table.concat(character.inventory.weapons, ", ") or "Aucune"),
        "  Armure: " .. (character.inventory.armor or "Aucune"),
        "",
        "👕 ÉQUIPEMENT:",
        "  Arme: " .. character.equipment.weapon .. " (Dégâts: +" .. Character.calculate_weapon_damage(character) .. ")",
        "  Armure: " .. character.equipment.armor .. " (Défense: +" .. Character.calculate_armor_defense(character) .. ")",
        "  Accessoire: " .. character.equipment.accessory,
        "",
        "🔮 SORTS ET CAPACITÉS:",
        "  Sorts: " .. table.concat(character.spells, ", "),
        "  Capacités: " .. table.concat(character.abilities, ", "),
        "",
        "📊 STATISTIQUES DE COMBAT:",
        "  Victoires: " .. character.combat_stats.wins,
        "  Défaites: " .. character.combat_stats.losses,
        "  Monstres vaincus: " .. character.combat_stats.monsters_defeated,
        "  Dégâts infligés: " .. character.combat_stats.damage_dealt,
        "  Dégâts reçus: " .. character.combat_stats.damage_taken,
        "  Coups critiques: " .. character.combat_stats.critical_hits,
        "",
        "╔════════════════════════════════════════════════════════════╗",
        "║                 PUISSANCE TOTALE: " .. Character.calculate_power_level(character) .. "               ║",
        "╚════════════════════════════════════════════════════════════╝"
    }
    
    return table.concat(stats, "\n")
end

-- Affiche les statistiques basiques (version compatible avec l'ancien système)
function Character.display_stats(character)
    return Character.display_detailed_stats(character)
end

-- Calcule les dégâts de l'arme
function Character.calculate_weapon_damage(character)
    local base_damage = math.floor(character.attributes.strength / 2)
    if character.equipment.weapon ~= "Poings" then
        return base_damage + 5  -- Bonus pour les armes
    end
    return base_damage
end

-- Calcule la défense de l'armure
function Character.calculate_armor_defense(character)
    local base_defense = math.floor(character.attributes.endurance / 3)
    if character.inventory.armor then
        return base_defense + 3  -- Bonus pour l'armure
    end
    return base_defense
end

-- Calcule le niveau de puissance global
function Character.calculate_power_level(character)
    local power = 0
    for _, value in pairs(character.attributes) do
        power = power + value
    end
    for _, value in pairs(character.skills) do
        power = power + value
    end
    power = power + (character.level * 10)
    power = power + character.combat_stats.monsters_defeated
    return power
end

-- Ajoute de l'expérience au personnage
function Character.add_experience(character, amount)
    character.experience = character.experience + amount
    
    -- Vérifier si le personnage monte de niveau
    while character.experience >= character.experience_to_next_level do
        character.experience = character.experience - character.experience_to_next_level
        character.level = character.level + 1
        character.experience_to_next_level = math.floor(character.experience_to_next_level * 1.5)
        
        -- Augmenter les statistiques lors du level up
        character.health_max = character.health_max + 5
        character.health = character.health_max
        character.energy_max = character.energy_max + 3
        character.energy = character.energy_max
        
        -- Augmenter légèrement les attributs
        for attr, _ in pairs(character.attributes) do
            character.attributes[attr] = character.attributes[attr] + 1
        end
        
        -- Recalculer les compétences
        character.skills.attack = math.floor((character.attributes.strength + character.attributes.dexterity) / 2)
        character.skills.defense = math.floor(character.attributes.endurance / 2)
        character.skills.magic_attack = math.floor((character.attributes.intelligence + character.attributes.magic) / 2)
        character.skills.magic_defense = math.floor(character.attributes.magic)
        character.skills.stealth = math.floor(character.attributes.dexterity / 2)
        character.skills.perception = math.floor(character.attributes.intelligence / 2)
    end
    
    return character.level
end

-- Restaure la santé
function Character.heal(character, amount)
    character.health = math.min(character.health + amount, character.health_max)
    return character.health
end

-- Restaure l'énergie
function Character.restore_energy(character, amount)
    character.energy = math.min(character.energy + amount, character.energy_max)
    return character.energy
end

-- Utilise une potion
function Character.use_potion(character)
    if character.inventory.potions > 0 then
        character.inventory.potions = character.inventory.potions - 1
        Character.heal(character, 20)
        Character.restore_energy(character, 15)
        return true, "Potion utilisée! Santé +20, Énergie +15"
    else
        return false, "Aucune potion disponible"
    end
end

-- Ajoute un objet à l'inventaire
function Character.add_to_inventory(character, item_type, item_name)
    if item_type == "weapon" then
        table.insert(character.inventory.weapons, item_name)
    elseif item_type == "armor" then
        character.inventory.armor = item_name
    elseif item_type == "potion" then
        character.inventory.potions = character.inventory.potions + 1
    elseif item_type == "gold" then
        character.inventory.gold = character.inventory.gold + item_name
    else
        table.insert(character.inventory.items, item_name)
    end
    return true
end

-- Équipe une arme
function Character.equip_weapon(character, weapon_name)
    for i, weapon in ipairs(character.inventory.weapons) do
        if weapon == weapon_name then
            character.equipment.weapon = weapon_name
            return true, "Arme équipée: " .. weapon_name
        end
    end
    return false, "Arme non trouvée dans l'inventaire"
end

-- Équipe une armure
function Character.equip_armor(character, armor_name)
    if character.inventory.armor == armor_name then
        character.equipment.armor = armor_name
        return true, "Armure équipée: " .. armor_name
    end
    return false, "Armure non trouvée dans l'inventaire"
end

return Character