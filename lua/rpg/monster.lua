-- monster.lua - Système de monstres RPG pour GNU-AI
-- Adapté du système IRC RPG

local RPGClasses = require("rpg.classes")

local Monster = {}

-- Crée un monstre
function Monster.create(monster_name, monster_class_name, level)
    local monster_class = RPGClasses.get_monster_class(monster_class_name)
    if not monster_class then
        return nil, "Classe de monstre invalide"
    end
    
    level = level or 1
    
    local monster = {
        name = monster_name,
        class = monster_class.name,
        level = level,
        attributes = {},
        spells = monster_class.base_spells or {},
        health = monster_class.base_health * level,
        health_max = monster_class.base_health * level,
        damage = monster_class.base_damage * level,
        armor = monster_class.base_armor * level
    }
    
    -- Appliquer les attributs de base
    for attribute, value in pairs(monster_class.base_attributes) do
        monster.attributes[attribute] = value * level
    end
    
    return monster
end

-- Affiche les statistiques d'un monstre
function Monster.display_stats(monster)
    local stats = {
        "=== STATISTIQUES DU MONSTRE ===",
        "Nom: " .. monster.name .. " (" .. monster.class .. ")",
        "Niveau: " .. monster.level,
        "Santé: " .. monster.health .. "/" .. monster.health_max,
        "Dégâts: " .. monster.damage,
        "Armure: " .. monster.armor,
        "Attributs:",
        "  Intelligence: " .. monster.attributes.intelligence,
        "  Force: " .. monster.attributes.strength,
        "  Dextérité: " .. monster.attributes.dexterity,
        "  Endurance: " .. monster.attributes.endurance,
        "  Magie: " .. monster.attributes.magic,
        "Sorts: " .. table.concat(monster.spells, ", ")
    }
    
    return table.concat(stats, "\n")
end

-- Obtient la liste des classes de monstres disponibles
function Monster.get_available_classes()
    return RPGClasses.get_available_monster_classes()
end

return Monster