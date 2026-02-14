-- main.lua - Programme principal avec intégration RPG et IRC

local RPGAgent = require("rpg.rpg_agent")
local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Combat = require("rpg.combat")

-- Fonction pour tester le combat avancé
local function test_advanced_combat()
    print("\n=== TEST: Combat Avancé avec Choix d'Actions ===")
    
    -- Créer des personnages
    local player = Character.create_with_attributes('Gandalf', 'mage', 10, {
        intelligence = 30, strength = 10, dexterity = 20, endurance = 20, magic = 20
    })
    
    local monster = Monster.create('Dragon', 'vampire', 8)
    
    -- Augmenter les points de vie pour un combat long
    player.health = 300
    player.health_max = 300
    monster.health = 350
    
    print(string.format("Combat: %s (Lvl %d) vs %s (Lvl %d)", 
        player.name, player.level, monster.name, monster.level))
    print(string.format("Santé: %d/%dHP vs %d/%dHP", 
        player.health, player.health_max, monster.health, monster.health_max))
    
    -- Créer un combat avec 2 dés
    local combat = Combat.create_combat_session(player, monster, 2, 0, nil)
    
    -- Exécuter 5 tours
    for i = 1, 5 do
        Combat.execute_turn(combat)
        if not combat.is_active then
            break
        end
    end
    
    print("\n📊 Résultat après 5 tours:")
    print(string.format("💪 %s: %d/%dHP | %s: %d/%dHP",
        player.name, player.health, player.health_max,
        monster.name, monster.health, monster.health_max))
    
    print("\n✅ Test du combat avancé terminé!")
end

-- Fonction pour tester le combat tour par tour
local function test_tour_by_tour_combat()
    print("\n=== TEST: Combat Tour par Tour Simplifié ===")
    
    -- Créer un contexte pour les paramètres
    local context = {next_combat_settings = {}}
    
    -- Créer des personnages
    local player = Character.create_with_attributes('Aragorn', 'humain', 10, {
        intelligence = 20, strength = 25, dexterity = 20, endurance = 25, magic = 10
    })
    
    local monster = Monster.create('Orc', 'loup_garou', 8)
    
    -- Donner plus de points de vie
    player.health = 300
    player.health_max = 300
    monster.health = 350
    
    print(string.format("Combat: %s vs %s", player.name, monster.name))
    
    -- Tour 1: Normal
    print("\n📌 Tour 1: Combat normal")
    context.next_combat_settings = {}
    local combat1 = Combat.create_combat_session(player, monster, 1, 0, nil)
    Combat.execute_turn(combat1)
    
    -- Tour 2: 3 dés
    print("\n📌 Tour 2: Avec 3 dés")
    context.next_combat_settings.num_dice = 3
    local combat2 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
    Combat.execute_turn(combat2)
    
    -- Tour 3: Avec magie
    print("\n📌 Tour 3: Avec action magie")
    context.next_combat_settings.player_action = "magie"
    local combat3 = Combat.create_combat_session(player, monster, context.next_combat_settings.num_dice, 0, nil)
    Combat.execute_turn(combat3)
    
    print("\n✅ Test du combat tour par tour terminé!")
end

-- Fonction principale
local function main()
    print("=== GNU-AI avec RPG et IRC ===")
    print("Système de jeu de rôle et client IRC intégré")
    print("\nMenu:")
    print("1. Exécuter l'agent RPG standard")
    print("2. Tester le combat avancé (avec IDs)")
    print("3. Tester le combat tour par tour (sans IDs)")
    print("4. Tout tester")
    
    local choice = io.read("*n") or 1
    
    if choice == 1 or choice == 4 then
        print("\n1. Exécution de l'agent RPG standard...")
        local rpg_agent = RPGAgent.create_rpg_agent()
        local rpg_context = rpg_agent.context
        rpg_agent.execute(rpg_context)
        
        if rpg_context.rpg_results then
            print("\n2. Résultats RPG:")
            print("- Personnage créé: " .. tostring(rpg_context.rpg_results.player_created))
            print("- Monstre créé: " .. tostring(rpg_context.rpg_results.monster_created))
            print("- Dés lancés: " .. tostring(rpg_context.rpg_results.dice_rolled))
            print("- Classes: " .. #rpg_context.rpg_results.available_character_classes .. " personnages, " .. #rpg_context.rpg_results.available_monster_classes .. " monstres")
        end
    end
    
    if choice == 2 or choice == 4 then
        test_advanced_combat()
    end
    
    if choice == 3 or choice == 4 then
        test_tour_by_tour_combat()
    end
    
    print("\n✅ Tous les tests terminés!")
    print("📝 Voir les fichiers COMBAT_ADVANCED.md et COMBAT_TOUR_BY_TOUR.md pour plus de détails.")
end

-- Exécuter le programme principal
main()