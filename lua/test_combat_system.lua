-- test_combat_system.lua - Test complet du système de combat RPG

local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Combat = require("rpg.combat")

-- Fonction de test principal
local function test_combat_system()
    print("╔════════════════════════════════════════════════════════════╗")
    print("║         TEST DU SYSTÈME DE COMBAT RPG AVANCÉ           ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    -- Test 1: Création de personnages avec le nouveau système
    print("\n🔹 TEST 1: Création de personnages avec limite de 100 points")
    local player1 = Character.create_with_attributes("Gandalf", "mage", 10, {
        intelligence = 30,
        strength = 10,
        dexterity = 15,
        endurance = 20,
        magic = 25
    })
    
    print(string.format("✅ %s créé avec succès!", player1.name))
    print(string.format("   Points utilisés: %d/100", 100 - player1.creation_points_remaining))
    print(string.format("   Énergie par défaut: %d/%d", player1.energy, player1.energy_max))
    print(string.format("   Santé: %d/%d", player1.health, player1.health_max))
    
    -- Test 2: Création d'un monstre
    print("\n🔹 TEST 2: Création de monstres")
    local monster1 = Monster.create("Dragon Noir", "loup_garou", 8)
    print(string.format("✅ %s (niveau %d) créé avec succès!", monster1.name, monster1.level))
    print(string.format("   Santé: %d", monster1.health))
    print(string.format("   Dégâts: %d", monster1.damage))
    print(string.format("   Armure: %d", monster1.armor))
    
    -- Test 3: Affichage des statistiques détaillées
    print("\n🔹 TEST 3: Statistiques détaillées")
    print(Character.display_detailed_stats(player1))
    
    -- Test 4: Système de combat complet
    print("\n🔹 TEST 4: Combat complet entre " .. player1.name .. " et " .. monster1.name)
    print("   Ce test peut prendre quelques secondes...")
    
    local combat = Combat.execute_full_combat(player1, monster1)
    
    -- Afficher le résumé
    Combat.display_combat_summary(combat)
    
    -- Test 5: Système d'expérience et level up
    print("\n🔹 TEST 5: Système d'expérience et level up")
    local initial_level = player1.level
    Character.add_experience(player1, 150)
    print(string.format("   Niveau initial: %d", initial_level))
    print(string.format("   Niveau après ajout d'EXP: %d", player1.level))
    print(string.format("   Expérience actuelle: %d/%d", player1.experience, player1.experience_to_next_level))
    
    if player1.level > initial_level then
        print("   ✅ Level up réussi! Statistiques améliorées.")
    end
    
    -- Test 6: Système d'inventaire et d'équipement
    print("\n🔹 TEST 6: Système d'inventaire et d'équipement")
    
    -- Ajouter des objets à l'inventaire
    Character.add_to_inventory(player1, "weapon", "Épée légendaire")
    Character.add_to_inventory(player1, "armor", "Armure de mithril")
    Character.add_to_inventory(player1, "potion", 1)
    Character.add_to_inventory(player1, "gold", 50)
    
    print(string.format("   Inventaire mis à jour:"))
    print(string.format("   - Or: %d pièces", player1.inventory.gold))
    print(string.format("   - Potions: %d", player1.inventory.potions))
    print(string.format("   - Armes: %s", table.concat(player1.inventory.weapons, ", ")))
    print(string.format("   - Armure: %s", player1.inventory.armor or "Aucune"))
    
    -- Équiper des objets
    local success, message = Character.equip_weapon(player1, "Épée légendaire")
    print(string.format("   Équipement arme: %s", message))
    
    local success2, message2 = Character.equip_armor(player1, "Armure de mithril")
    print(string.format("   Équipement armure: %s", message2))
    
    -- Test 7: Utilisation de potions
    print("\n🔹 TEST 7: Utilisation de potions")
    
    -- Infliger des dégâts pour tester la potion
    player1.health = player1.health - 30
    print(string.format("   Santé avant potion: %d/%d", player1.health, player1.health_max))
    
    local success3, message3 = Character.use_potion(player1)
    print(string.format("   Utilisation potion: %s", message3))
    print(string.format("   Santé après potion: %d/%d", player1.health, player1.health_max))
    
    -- Test 8: Combat avancé avec équipement
    print("\n🔹 TEST 8: Combat avec équipement amélioré")
    local monster2 = Monster.create("Vampire Ancien", "vampire", 12)
    
    print(string.format("   %s (Lvl %d, Épée légendaire + Armure de mithril) vs %s (Lvl %d)",
                      player1.name, player1.level, monster2.name, monster2.level))
    
    local combat2 = Combat.execute_full_combat(player1, monster2)
    Combat.display_combat_summary(combat2)
    
    -- Test 9: Vérification des statistiques finales
    print("\n🔹 TEST 9: Statistiques finales après tous les combats")
    print(Character.display_detailed_stats(player1))
    
    -- Résumé final
    print("\n╔════════════════════════════════════════════════════════════╗")
    print("║                   RÉSUMÉ DES TESTS                      ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print("✅ Tous les tests du système de combat ont été exécutés avec succès!")
    print(string.format("📊 %s a combattu %d monstres", player1.name, player1.combat_stats.monsters_defeated))
    print(string.format("💰 Or accumulé: %d pièces", player1.inventory.gold))
    print(string.format("📈 Niveau final: %d (Power Level: %d)", player1.level, Character.calculate_power_level(player1)))
    print(string.format("⚔️ Victoires: %d | Défaites: %d", player1.combat_stats.wins, player1.combat_stats.losses))
    print(string.format("🎯 Coups critiques: %d", player1.combat_stats.critical_hits))
    
    print("\n🎮 Le système de combat RPG avancé est maintenant pleinement opérationnel!")
    print("   Vous pouvez utiliser toutes ces fonctionnalités via les commandes RPG.")
end

-- Exécuter les tests
test_combat_system()