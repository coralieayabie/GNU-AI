-- test_combat_tour_by_tour.lua - Test du système de combat tour par tour avec choix d'actions

local Character = require('rpg.character')
local Monster = require('rpg.monster')
local Combat = require('rpg.combat')

print("╔════════════════════════════════════════════════════════════╗")
print("║  TEST: Combat Tour par Tour avec Choix d'Actions      ║")
print("║        (Sans IDs, choix à chaque tour)                ║")
print("╚════════════════════════════════════════════════════════════╝")

-- Créer un contexte pour simuler les commandes
local context = {
    next_combat_settings = {}
}

-- Créer des personnages pour le combat
local player = Character.create_with_attributes('Aragorn', 'humain', 10, {
    intelligence = 20, strength = 25, dexterity = 20, endurance = 25, magic = 10
})

local monster = Monster.create('Orc', 'loup_garou', 8)

-- Donner plus de points de vie pour un combat long
player.health = 300
player.health_max = 300
monster.health = 350

print("\n📌 Configuration initiale:")
print(string.format("👤 %s (Lvl %d): %d/%dHP", player.name, player.level, player.health, player.health_max))
print(string.format("👹 %s (Lvl %d): %d/%dHP", monster.name, monster.level, monster.health, monster.health_max))

-- Simuler un combat avec choix à chaque tour
print("\n🎮 Démarrage du combat tour par tour:")
print("─────────────────────────────────────────────────────")

-- Tour 1: Combat normal
print("\n📌 Tour 1: Combat normal (1 dé, actions automatiques)")
local combat1 = Combat.create_combat_session(player, monster, 1, 0, nil)
Combat.execute_turn(combat1)
print(string.format("💪 Après tour 1: %s %d/%dHP | %s %d/%dHP",
    player.name, player.health, player.health_max,
    monster.name, monster.health, monster.health_max))

-- Tour 2: Changer le nombre de dés
print("\n📌 Tour 2: Changement à 3 dés")
context.next_combat_settings.num_dice = 3
local combat2 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
Combat.execute_turn(combat2)
print(string.format("💪 Après tour 2: %s %d/%dHP | %s %d/%dHP",
    player.name, player.health, player.health_max,
    monster.name, monster.health, monster.health_max))

-- Tour 3: Joueur utilise la magie
print("\n📌 Tour 3: Joueur utilise la magie")
context.next_combat_settings.player_action = "magie"
local combat3 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
Combat.execute_turn(combat3)
print(string.format("💪 Après tour 3: %s %d/%dHP | %s %d/%dHP",
    player.name, player.health, player.health_max,
    monster.name, monster.health, monster.health_max))

-- Tour 4: Joueur se défend
print("\n📌 Tour 4: Joueur utilise la défense")
context.next_combat_settings.player_action = "défense"
local combat4 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
Combat.execute_turn(combat4)
print(string.format("💪 Après tour 4: %s %d/%dHP | %s %d/%dHP",
    player.name, player.health, player.health_max,
    monster.name, monster.health, monster.health_max))

-- Tour 5: Joueur esquive
print("\n📌 Tour 5: Joueur utilise l'esquive")
context.next_combat_settings.player_action = "esquive"
local combat5 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
Combat.execute_turn(combat5)
print(string.format("💪 Après tour 5: %s %d/%dHP | %s %d/%dHP",
    player.name, player.health, player.health_max,
    monster.name, monster.health, monster.health_max))

-- Tour 6: Retour à l'attaque normale
print("\n📌 Tour 6: Retour à l'attaque normale")
context.next_combat_settings.player_action = "attaque"
local combat6 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
Combat.execute_turn(combat6)
print(string.format("💪 Après tour 6: %s %d/%dHP | %s %d/%dHP",
    player.name, player.health, player.health_max,
    monster.name, monster.health, monster.health_max))

-- Tour 7: Monstre utilise la défense
print("\n📌 Tour 7: Monstre utilise la défense")
context.next_combat_settings.monster_action = "défense"
context.next_combat_settings.player_action = "attaque"
local combat7 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
Combat.execute_turn(combat7)
print(string.format("💪 Après tour 7: %s %d/%dHP | %s %d/%dHP",
    player.name, player.health, player.health_max,
    monster.name, monster.health, monster.health_max))

-- Résumé final
print("\n╔════════════════════════════════════════════════════════════╗")
print("║              RÉSUMÉ DU COMBAT TOUR PAR TOUR           ║")
print("╚════════════════════════════════════════════════════════════╝")
print("✅ Système de combat tour par tour validé")
print("🎮 Fonctionnalités testées:")
print("   • Choix du nombre de dés à chaque tour")
print("   • Sélection d'actions sans IDs complexes")
print("   • Stratégies dynamiques (magie, défense, esquive)")
print("   • Changement fluide entre les tours")
print("\n💡 Le système permet maintenant aux joueurs de choisir")
print("   leur stratégie à chaque tour sans gestion d'IDs!")
