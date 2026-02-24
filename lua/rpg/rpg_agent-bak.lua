-- rpg_agent.lua - Agent RPG pour GNU-AI
-- Intègre le système RPG avec l'architecture d'agents existante

local Character = require("rpg.character")
local Monster = require("rpg.monster")
local Dice = require("rpg.dice")
local RPGClasses = require("rpg.classes")
local RPGCommands = require("rpg.commands")

local RPGAgent = {}

-- Fonction d'exécution principale de l'agent RPG
function RPGAgent.execute(context)
    print("=== AGENT RPG GNU-AI ===")
    print("Système de jeu de rôle intégré avec succès!")
    print("Tapez 'help' pour voir les commandes disponibles")
    
    -- Démo rapide si aucun contexte spécifique
    if not context.demo_done then
        print("\n--- DÉMONSTRATION RAPIDE ---")
        
        -- Créer un personnage par défaut pour démonstration
        local player = Character.create_default()
        context.characters["Héros"] = player
        print("\n" .. Character.display_stats(player))
        
        -- Créer un monstre pour démonstration
        local monster, err = Monster.create("Dragon Noir", "loup_garou", 5)
        if monster then
            context.monsters["Dragon Noir"] = monster
            print("\n" .. Monster.display_stats(monster))
        else
            print("Erreur création monstre: " .. err)
        end
        
        -- Démonstration du système de dés
        print("\n=== LANCER DE DÉS ===")
        print("Lancement de 3 dés: " .. Dice.roll_and_format(3))
        
        context.demo_done = true
    end
    
    -- Afficher les classes disponibles
    print("\n=== CLASSES DISPONIBLES ===")
    print("Personnages: " .. table.concat(RPGClasses.get_available_character_classes(), ", "))
    print("Monstres: " .. table.concat(RPGClasses.get_available_monster_classes(), ", "))
    
    -- Mettre à jour le contexte avec les résultats RPG
    context.rpg_results = {
        player_created = true,
        monster_created = context.monsters["Dragon Noir"] ~= nil,
        dice_rolled = true,
        available_character_classes = RPGClasses.get_available_character_classes(),
        available_monster_classes = RPGClasses.get_available_monster_classes(),
        characters = context.characters,
        monsters = context.monsters
    }
    
    print("\n✅ Agent RPG prêt à recevoir des commandes!")
end

-- Fonction pour exécuter une commande RPG
function RPGAgent.execute_command(command_str, context)
    return RPGCommands.execute_command(command_str, context)
end

-- Fonction pour créer un agent RPG compatible avec le système GNU-AI
function RPGAgent.create_rpg_agent()
    return {
        name = "RPGAgent",
        execute = RPGAgent.execute,
        execute_command = RPGAgent.execute_command,
        context = {
            rpg_results = nil,
            characters = {},
            monsters = {},
            demo_done = false
        }
    }
end

return RPGAgent
