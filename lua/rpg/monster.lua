-- Système de monstres RPG
local RPGClasses = require("rpg.classes")

local Monster = {}

function Monster.create(name, class_name, level)
    local monster_class = RPGClasses.get_monster_class(class_name)
    if not monster_class then
        return nil, "Classe de monstre invalide"
    end

    level = level or 1

    return {
        name = name,
        class = monster_class.name,
        level = level,
        attributes = monster_class.base_attributes,
        health = monster_class.base_health * level,
        health_max = monster_class.base_health * level,
        damage = monster_class.base_damage * level,
        armor = monster_class.base_armor * level,
        spells = monster_class.base_spells or {}
    }
end

function Monster.display_stats(monster)
    return string.format(
        "=== %s (Lvl %d) ===\n" ..
        "Classe: %s\n" ..
        "Santé: %d/%d\n" ..
        "Dégâts: %d\n" ..
        "Armure: %d",
        monster.name, monster.level, monster.class,
        monster.health, monster.health_max,
        monster.damage, monster.armor
    )
end

return Monster

