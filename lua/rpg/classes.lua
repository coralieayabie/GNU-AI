-- rpg/classes.lua - Définition des classes RPG
local RPGClasses = {}

-- Classes de personnages
RPGClasses.character_classes = {
    mage = {
        name = "Mage",
        description = "Maître des éléments et des sorts",
        base_attributes = {
            intelligence = 8, strength = 2, dexterity = 4,
            endurance = 3, magic = 10
        },
        base_health = 80,
        base_spells = {"Boule de feu", "Éclair", "Bouclier magique"}
    },
    humain = {
        name = "Humain",
        description = "Polyvalent et équilibré",
        base_attributes = {
            intelligence = 5, strength = 5, dexterity = 5,
            endurance = 5, magic = 5
        },
        base_health = 100,
        base_spells = {"Coup d'épée", "Bouclier"}
    },
    hobbit = {
        name = "Hobbit",
        description = "Agile et furtif",
        base_attributes = {
            intelligence = 4, strength = 2, dexterity = 8,
            endurance = 3, magic = 3
        },
        base_health = 60,
        base_spells = {"Disparition", "Coup rapide"}
    },
    elfe = {
        name = "Elfe",
        description = "Rapide et précis",
        base_attributes = {
            intelligence = 6, strength = 3, dexterity = 7,
            endurance = 4, magic = 6
        },
        base_health = 70,
        base_spells = {"Tir précis", "Flèche magique"}
    }
}

-- Classes de monstres
RPGClasses.monster_classes = {
    loup_garou = {
        name = "Loup-garou",
        description = "Créature rapide et puissante",
        base_attributes = {
            intelligence = 4, strength = 8, dexterity = 7,
            endurance = 6, magic = 3
        },
        base_health = 60,
        base_damage = 10,
        base_armor = 5
    },
    vampire = {
        name = "Vampire",
        description = "Immortel avec régénération",
        base_attributes = {
            intelligence = 7, strength = 6, dexterity = 8,
            endurance = 5, magic = 7
        },
        base_health = 70,
        base_damage = 9,
        base_armor = 4
    }
}

-- Fonctions utilitaires
function RPGClasses.get_character_class(class_name)
    return RPGClasses.character_classes[class_name:lower()]
end

function RPGClasses.get_monster_class(class_name)
    return RPGClasses.monster_classes[class_name:lower()]
end

function RPGClasses.get_available_character_classes()
    local classes = {}
    for name, _ in pairs(RPGClasses.character_classes) do
        table.insert(classes, name)
    end
    return classes
end

function RPGClasses.get_available_monster_classes()
    local classes = {}
    for name, _ in pairs(RPGClasses.monster_classes) do
        table.insert(classes, name)
    end
    return classes
end

return RPGClasses

