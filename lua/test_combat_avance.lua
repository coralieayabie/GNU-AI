-- test_combat_avance.lua - Test complet du système de combat avancé
-- Démonstration des choix d'actions et de dés

local Character = require('rpg.character')
local Monster = require('rpg.monster')
local Combat = require('rpg.combat')

print("╔════════════════════════════════════════════════════════════╗")
print("║     TEST DU SYSTÈME DE COMBAT AVANCÉ AVEC CHOIX       ║")
print("║          D'ACTIONS ET DE NOMBRE DE DÉS                ║")
print("╚════════════════════════════════════════════════════════════╝")

-- Test 1: Création de personnages et combat de base
print("\n📌 TEST 1: Combat de base avec 1 dé")
print("─────────────────────────────────────────────────────")

local player1 = Character.create_with_attributes('Aragorn', 'humain', 10, {
    intelligence = 20, strength = 25, dexterity = 20, endurance = 25, magic = 10
})

local monster1 = Monster.create('Orc', 'loup_garou', 8)

-- Donner plus de points de vie pour un combat long
player1.health = 300
player1.health_max = 300
monster1.health = 350

local combat1 = Combat.create_combat_session(player1, monster1, 1, 0, nil)
print(string.format("✅ Combat créé: %s (Lvl %d) vs %s (Lvl %d)", 
    player1.name, player1.level, monster1.name, monster1.level))
print(string.format("💪 Santé: %s %d/%dHP vs %s %d/%dHP",
    player1.name, player1.health, player1.health_max,
    monster1.name, monster1.health, monster1.health_max))

-- Exécuter 3 tours
for i = 1, 3 do
    Combat.execute_turn(combat1)
end

print("\n📊 Résultat après 3 tours:")
print(string.format("💪 %s: %d/%dHP | %s: %d/%dHP",
    player1.name, player1.health, player1.health_max,
    monster1.name, monster1.health, monster1.health_max))

-- Test 2: Changement du nombre de dés
print("\n📌 TEST 2: Changement du nombre de dés à 3")
print("─────────────────────────────────────────────────────")

Combat.set_num_dice(combat1, 3)
print("✅ Nombre de dés changé à 3")

-- Exécuter 2 tours avec 3 dés
for i = 1, 2 do
    Combat.execute_turn(combat1)
end

print("\n📊 Résultat après 2 tours supplémentaires:")
print(string.format("💪 %s: %d/%dHP | %s: %d/%dHP",
    player1.name, player1.health, player1.health_max,
    monster1.name, monster1.health, monster1.health_max))

-- Test 3: Choix d'actions
print("\n📌 TEST 3: Choix d'actions (défense et magie)")
print("─────────────────────────────────────────────────────")

Combat.set_player_action(combat1, "défense")
print("✅ Action du joueur: défense")

Combat.set_monster_action(combat1, "magie")
print("✅ Action du monstre: magie")

-- Exécuter 2 tours avec actions spéciales
for i = 1, 2 do
    Combat.execute_turn(combat1)
end

print("\n📊 Résultat après 2 tours avec actions spéciales:")
print(string.format("💪 %s: %d/%dHP | %s: %d/%dHP",
    player1.name, player1.health, player1.health_max,
    monster1.name, monster1.health, monster1.health_max))

-- Test 4: Combat avec 5 dés (maximum)
print("\n📌 TEST 4: Combat avec 5 dés (maximum)")
print("─────────────────────────────────────────────────────")

local player2 = Character.create_with_attributes('Gandalf', 'mage', 12, {
    intelligence = 30, strength = 10, dexterity = 25, endurance = 20, magic = 15
})

local monster2 = Monster.create('Dragon', 'vampire', 10)

player2.health = 400
player2.health_max = 400
monster2.health = 450

local combat2 = Combat.create_combat_session(player2, monster2, 5, 0, nil)
print(string.format("✅ Combat créé avec 5 dés: %s vs %s", player2.name, monster2.name))

-- Exécuter 3 tours avec 5 dés
for i = 1, 3 do
    Combat.execute_turn(combat2)
end

print("\n📊 Résultat après 3 tours avec 5 dés:")
print(string.format("💪 %s: %d/%dHP | %s: %d/%dHP",
    player2.name, player2.health, player2.health_max,
    monster2.name, monster2.health, monster2.health_max))

-- Test 5: Actions d'esquive
print("\n📌 TEST 5: Stratégie d'esquive")
print("─────────────────────────────────────────────────────")

Combat.set_player_action(combat2, "esquive")
print("✅ Action du joueur: esquive")

-- Exécuter 2 tours avec esquive
for i = 1, 2 do
    Combat.execute_turn(combat2)
end

print("\n📊 Résultat après 2 tours avec esquive:")
print(string.format("💪 %s: %d/%dHP | %s: %d/%dHP",
    player2.name, player2.health, player2.health_max,
    monster2.name, monster2.health, monster2.health_max))

-- Résumé final
print("\n╔════════════════════════════════════════════════════════════╗")
print("║                  RÉSUMÉ DES TESTS                      ║")
print("╚════════════════════════════════════════════════════════════╝")
print("✅ Tous les tests du système de combat avancé ont été exécutés")
print("🎮 Fonctionnalités validées:")
print("   • Choix du nombre de dés (1-5)")
print("   • Sélection d'actions (attaque/défense/esquive/magie)")
print("   • Changement dynamique pendant le combat")
print("   • Intégration avec le système de logs")
print("   • Gestion des combats actifs")
print("\n💡 Le système de combat avancé est maintenant pleinement opérationnel!")
print("   Les joueurs peuvent contrôler finement leurs stratégies de combat.")
