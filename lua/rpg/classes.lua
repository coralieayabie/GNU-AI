-- classes.lua - Définition des classes RPG pour GNU-AI
-- Adapté du système IRC RPG

local RPGClasses = {}

-- Classes de personnages jouables
RPGClasses.character_classes = {
    mage = {
        name = "Mage",
        description = "Un puissant utilisateur de magie.",
        base_attributes = {
            intelligence = 8,
            strength = 2,
            dexterity = 4,
            endurance = 3,
            magic = 10
        },
        base_spells = {"Boule de feu", "Éclair", "Bouclier magique"},
        base_energy = 100,
        base_energy_max = 100
    },
    
    humain = {
        name = "Humain",
        description = "Un personnage polyvalent.",
        base_attributes = {
            intelligence = 5,
            strength = 5,
            dexterity = 5,
            endurance = 5,
            magic = 5
        },
        base_spells = {"Coup d'épée", "Bouclier"},
        base_energy = 80,
        base_energy_max = 80
    },
    
    hobbit = {
        name = "Hobbit",
        description = "Un personnage agile et furtif.",
        base_attributes = {
            intelligence = 4,
            strength = 2,
            dexterity = 8,
            endurance = 3,
            magic = 3
        },
        base_spells = {"Disparition", "Coup rapide"},
        base_energy = 60,
        base_energy_max = 60
    },
    
    elfe = {
        name = "Elfe",
        description = "Un personnage rapide et précis.",
        base_attributes = {
            intelligence = 6,
            strength = 3,
            dexterity = 7,
            endurance = 4,
            magic = 6
        },
        base_spells = {"Tir précis", "Flèche magique"},
        base_energy = 70,
        base_energy_max = 70
    }
}

-- Classes de monstres
RPGClasses.monster_classes = {
    loup_garou = {
        name = "Loup-garou",
        description = "Un monstre rapide et puissant.",
        base_attributes = {
            intelligence = 4,
            strength = 8,
            dexterity = 7,
            endurance = 6,
            magic = 3
        },
        base_spells = {"Griffes acérées", "Hurlement terrifiant"},
        base_health = 60,
        base_damage = 10,
        base_armor = 5
    },
    
    vampire = {
        name = "Vampire",
        description = "Un monstre immortel avec régénération.",
        base_attributes = {
            intelligence = 7,
            strength = 6,
            dexterity = 8,
            endurance = 5,
            magic = 7
        },
        base_spells = {"Morsure vampirique", "Régénération"},
        base_health = 70,
        base_damage = 9,
        base_armor = 4
    }
}

-- Fonction pour obtenir une classe par nom
function RPGClasses.get_character_class(class_name)
    return RPGClasses.character_classes[class_name:lower()]
end

-- Fonction pour obtenir une classe de monstre par nom
function RPGClasses.get_monster_class(class_name)
    return RPGClasses.monster_classes[class_name:lower()]
end

-- Fonction pour obtenir la liste des classes disponibles
function RPGClasses.get_available_character_classes()
    local class_list = {}
    for class_name, _ in pairs(RPGClasses.character_classes) do
        table.insert(class_list, class_name)
    end
    return class_list
end

function RPGClasses.get_available_monster_classes()
    local class_list = {}
    for class_name, _ in pairs(RPGClasses.monster_classes) do
        table.insert(class_list, class_name)
    end
    return class_list
end

return RPGClasses