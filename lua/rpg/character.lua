-- Système de personnages RPG
local RPGClasses = require("rpg.classes")
local config = require("config")

local Character = {}
Character.__index = Character

function Character.create_with_attributes(name, class_name, level, attrs)
    local character_class = RPGClasses.get_character_class(class_name) or
                           RPGClasses.get_character_class("humain")

    -- Calculer les points utilisés
    local total_points = 0
    for _, value in pairs(attrs) do
        total_points = total_points + (value or 0)
    end

    if total_points > config.game.creation_points then
        return nil, "La somme des attributs ne peut pas dépasser " ..
               config.game.creation_points .. " points"
    end

    return {
        name = name,
        class = character_class.name,
        level = level or 1,
        experience = 0,
        experience_to_next_level = 100,
        attributes = {
            intelligence = attrs.intelligence or character_class.base_attributes.intelligence or 5,
            strength = attrs.strength or character_class.base_attributes.strength or 5,
            dexterity = attrs.dexterity or character_class.base_attributes.dexterity or 5,
            endurance = attrs.endurance or character_class.base_attributes.endurance or 5,
            magic = attrs.magic or character_class.base_attributes.magic or 5
        },
        health = math.floor((character_class.base_health or 100) / 10) * level,
        health_max = math.floor((character_class.base_health or 100) / 10) * level,
        energy = config.game.default_energy,
        energy_max = config.game.default_energy,
        inventory = {gold = 100, items = {}, weapons = {}, armor = nil, potions = 0},
        equipment = {weapon = "Poings", armor = "Vêtements", accessory = "Aucun"}
    }
end

function Character.display_detailed_stats(character)
    return string.format(
        "=== %s (Lvl %d %s) ===\n" ..
        "Santé: %d/%d\n" ..
        "Énergie: %d/%d\n" ..
        "Attributs:\n" ..
        "  Intelligence: %d | Force: %d\n" ..
        "  Dextérité: %d | Endurance: %d\n" ..
        "  Magie: %d\n" ..
        "Équipement: %s (Arme), %s (Armure)",
        character.name, character.level, character.class,
        character.health, character.health_max,
        character.energy, character.energy_max,
        character.attributes.intelligence, character.attributes.strength,
        character.attributes.dexterity, character.attributes.endurance,
        character.attributes.magic,
        character.equipment.weapon, character.equipment.armor or "Aucune"
    )
end

return Character

