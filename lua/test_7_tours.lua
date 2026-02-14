-- test_7_tours.lua - Système de combat avancé avec 7 tours et actions variées

local Character = require('rpg.character')
local Monster = require('rpg.monster')
local Combat = require('rpg.combat')

-- Fonction pour créer un combat avec actions variées
function create_advanced_combat(num_dice, max_turns)
    -- Créer un mage puissant (100 points exactement)
    local player = Character.create_with_attributes('Gandalf', 'mage', 15, {
        intelligence = 30, strength = 10, dexterity = 20, endurance = 20, magic = 20
    })
    
    -- Créer un monstre puissant
    local monster = Monster.create('Dragon Noir', 'vampire', 12)
    
    -- Augmenter les points de vie pour un combat long
    player.health = 500
    player.health_max = 500
    monster.health = 600
    
    -- Créer un combat avec les paramètres
    local combat = Combat.create_combat_session(player, monster, num_dice, max_turns)
    
    return combat, player, monster
end

-- Fonction pour simuler un combat avec actions variées
function simulate_advanced_combat(num_dice, max_turns)
    local combat, player, monster = create_advanced_combat(num_dice, max_turns)
    
    print(string.format('Combat avancé: %d dés, %d tours max', num_dice, max_turns))
    print('============================================')
    
    -- Exécuter le combat
    while combat.is_active do
        Combat.execute_turn(combat)
    end
    
    -- Afficher le journal
    for i, entry in ipairs(combat.log) do
        print(entry)
    end
    
    print('\nRésumé:')
    Combat.display_combat_summary(combat)
    
    return combat
end

-- Tester différents scénarios
print('SCÉNARIO 1: Combat avec 1 dé, 7 tours')
print('====================================')
simulate_advanced_combat(1, 7)

print('\n\nSCÉNARIO 2: Combat avec 2 dés, 7 tours')
print('======================================')
simulate_advanced_combat(2, 7)

print('\n\nSCÉNARIO 3: Combat avec 3 dés, 7 tours')
print('======================================')
simulate_advanced_combat(3, 7)
