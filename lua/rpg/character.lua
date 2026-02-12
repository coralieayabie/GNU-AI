-- character.lua - Système de personnages RPG avancé pour GNU-AI
-- Version corrigée et simplifiée

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
        error("Erreur: La somme des attributs ne peut pas dépasser " .. MAX_CREATION_POINTS .. " points")
    end
    
    -- Initialiser les attributs de base avec valeurs par défaut
    local base_attributes = character_class.base_attributes or {
        intelligence = 5, strength = 5, dexterity = 5, endurance = 5, magic = 5
    }
    local base_energy = character_class.base_energy or character_class.base_energy_max or 100
    points_distribution = points_distribution or {}
    
    -- Créer les attributs
    local attrs = {
        intelligence = points_distribution.intelligence or base_attributes.intelligence,
        strength = points_distribution.strength or base_attributes.strength,
        dexterity = points_distribution.dexterity or base_attributes.dexterity,
        endurance = points_distribution.endurance or base_attributes.endurance,
        magic = points_distribution.magic or base_attributes.magic
    }
    
    -- Créer le personnage
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
        skills = {},
        inventory = {
            gold = 100,
            items = {},
            weapons = {},
            armor = nil,
            potions = 0
        },
        equipment = {
            weapon = "Poings",
            armor = "Vêtements",
            accessory = "Aucun"
        },
        spells = character_class.base_spells or {},
        abilities = {"Attaque basique", "Défense", "Esquive"},
        combat_stats = {
            wins = 0, losses = 0, monsters_defeated = 0,
            damage_dealt = 0, damage_taken = 0, critical_hits = 0
        }
    }
    
    -- Calculer les compétences après la création
    character.skills.attack = math.floor((character.attributes.strength + character.attributes.dexterity) / 2)
    character.skills.defense = math.floor(character.attributes.endurance / 2)
    character.skills.magic_attack = math.floor((character.attributes.intelligence + character.attributes.magic) / 2)
    character.skills.magic_defense = math.floor(character.attributes.magic)
    character.skills.stealth = math.floor(character.attributes.dexterity / 2)
    character.skills.perception = math.floor(character.attributes.intelligence / 2)
    character.creation_points_remaining = MAX_CREATION_POINTS - total_points
    
    return character
end

function Character.create_default()
    return Character.create_with_attributes("Héros", "humain", 1, {
        intelligence = 20, strength = 20, dexterity = 20, endurance = 20, magic = 20
    })
end

function Character.display_detailed_stats(character)
    return string.format("=== %s (Lvl %d) ===\nSanté: %d/%d\nÉnergie: %d/%d\nAttaque: %d\nDéfense: %d",
    character.name, character.level,
    character.health, character.health_max,
    character.energy, character.energy_max,
    character.skills.attack, character.skills.defense)
end

function Character.display_stats(character)
    return Character.display_detailed_stats(character)
end

function Character.calculate_weapon_damage(character)
    return math.floor(character.attributes.strength / 2) + (character.equipment.weapon ~= "Poings" and 5 or 0)
end

function Character.calculate_armor_defense(character)
    return math.floor(character.attributes.endurance / 3) + (character.inventory.armor and 3 or 0)
end

function Character.calculate_power_level(character)
    local power = 0
    for _, v in pairs(character.attributes) do power = power + v end
    for _, v in pairs(character.skills) do power = power + v end
    return power + (character.level * 10) + character.combat_stats.monsters_defeated
end

function Character.add_experience(character, amount)
    character.experience = character.experience + amount
    while character.experience >= character.experience_to_next_level do
        character.experience = character.experience - character.experience_to_next_level
        character.level = character.level + 1
        character.experience_to_next_level = math.floor(character.experience_to_next_level * 1.5)
        character.health_max = character.health_max + 5
        character.health = character.health_max
        character.energy_max = character.energy_max + 3
        character.energy = character.energy_max
        for attr, _ in pairs(character.attributes) do character.attributes[attr] = character.attributes[attr] + 1 end
        character.skills.attack = math.floor((character.attributes.strength + character.attributes.dexterity) / 2)
        character.skills.defense = math.floor(character.attributes.endurance / 2)
        character.skills.magic_attack = math.floor((character.attributes.intelligence + character.attributes.magic) / 2)
    end
    return character.level
end

function Character.heal(character, amount)
    character.health = math.min(character.health + amount, character.health_max)
    return character.health
end

function Character.restore_energy(character, amount)
    character.energy = math.min(character.energy + amount, character.energy_max)
    return character.energy
end

function Character.use_potion(character)
    if character.inventory.potions > 0 then
        character.inventory.potions = character.inventory.potions - 1
        return true, "Potion utilisée! Santé +20, Énergie +15"
    end
    return false, "Aucune potion disponible"
end

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
end

function Character.equip_weapon(character, weapon_name)
    for _, weapon in ipairs(character.inventory.weapons) do
        if weapon == weapon_name then
            character.equipment.weapon = weapon_name
            return true, "Arme équipée: " .. weapon_name
        end
    end
    return false, "Arme non trouvée"
end

function Character.equip_armor(character, armor_name)
    if character.inventory.armor == armor_name then
        character.equipment.armor = armor_name
        return true, "Armure équipée: " .. armor_name
    end
    return false, "Armure non trouvée"
end

return Character