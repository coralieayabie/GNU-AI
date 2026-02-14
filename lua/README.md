# GNU-AI Lua Version avec RPG Intégré

Conversion du projet GNU-AI de C vers Lua avec intégration d'un système RPG complet.

## Structure

- `agent.lua` - Système d'agents (équivalent de agent.h/agent.c)
- `web.lua` - Module de recherche web (équivalent de web.h/web.c) 
- `main.lua` - Programme principal (équivalent de main.c)
- `rpg/` - Module RPG intégré (nouveau)
  - `rpg_agent.lua` - Agent RPG principal
  - `character.lua` - Système de personnages
  - `monster.lua` - Système de monstres
  - `dice.lua` - Système de dés
  - `classes.lua` - Définition des classes
  - `commands.lua` - Système de commandes unifié

## Dépendances

Pour exécuter ce code Lua, vous aurez besoin de :

1. **Lua 5.1+** - Installé sur votre système
2. **LuaSocket** - Pour le client IRC et les connexions réseau :
   - `luarocks install luasocket` (méthode recommandée)
   - Ou via votre gestionnaire de paquets système: `sudo apt-get install lua-socket`

### Configuration

Le bot utilise un fichier `config.lua` pour la configuration. Vous pouvez modifier:
- Serveur IRC, port, nickname
- Canaux par défaut
- Paramètres de timeout et reconnexion
- Configuration du jeu (niveaux max, etc.)

## Installation

### Méthode 1: Avec LuaRocks (recommandé)
```bash
# Installer Lua si ce n'est pas déjà fait
sudo apt-get install lua5.1

# Installer luarocks (gestionnaire de paquets Lua)
sudo apt-get install luarocks

# Installer LuaSocket
luarocks install luasocket
```

### Méthode 2: Via paquets système (Ubuntu/Debian)
```bash
sudo apt-get install lua5.1 lua-socket
```

### Méthode 3: Installation manuelle
Si vous ne pouvez pas installer LuaSocket, vous pouvez désactiver le module web
en modifiant `main.lua` pour ne pas exécuter l'agent web.

## Exécution

### Mode RPG pur (sans IRC) :
```bash
cd lua
lua main_rpg_only.lua
```

### Mode IRC Basique :
```bash
cd lua
lua main_irc.lua
```

### Mode IRC Amélioré (inspiré de RGP-IRC_GAME) :
```bash
cd lua
lua main_irc_improved.lua
```

### Mode test complet :
```bash
cd lua
lua test_combat_system.lua
```

### Mode test d'intégration :
```bash
cd lua
lua test_rpg_integration.lua
```

### Si vous avez des problèmes de dépendances :
Utilisez `main_rpg_only.lua` qui ne nécessite aucune bibliothèque externe.

## Fonctionnalités Intégrées

### 🎭 Système de Personnages RPG
- **4 Classes jouables** : Mage, Humain, Hobbit, Elfe
- **5 Attributs** : Intelligence, Force, Dextérité, Endurance, Magie
- **Système d'énergie** (équivalent des points de vie)
- **Niveaux 1-100** avec progression
- **Sorts spécifiques** par classe
- **Limite de 100 points** pour la création de personnages

### 👹 Système de Monstres
- **2 Classes de monstres** : Loup-garou, Vampire
- **Statistiques complètes** : Santé, Dégâts, Armure
- **Niveaux et attributs** similaires aux personnages
- **Capacités spéciales** par monstre

### 🎲 Système de Dés
- **Lancer de dés à 6 faces** (d6)
- **Support multi-dés** (jusqu'à 10 dés)
- **Formatage des résultats** clair et lisible

### ⚔️ Système de Combat Avancé
- **Combats tour par tour** entre joueurs et monstres
- **Règles de combat** : esquive, blocage, coups critiques
- **Gestion d'expérience** et level up
- **Récompenses et butin** après les victoires

#### 🎮 Mécaniques de Combat Détaillées

**Tour par tour** : Les joueurs et monstres alternent les attaques

**Esquive** (🛡️) :
- Chance de base : 15%
- Bonus : +Dextérité/2 ou +Furtivité
- Formule : `chance_esquive = 15 + (dexterité/2) ou (furtivité)`

**Blocage** (🔥) :
- Chance de base : 20%
- Bonus : +Endurance/3 ou +Défense
- Réduction : 70% des dégâts
- Formule : `chance_blocage = 20 + (endurance/3) ou (défense)`

**Coups critiques** (🎯) :
- Chance de base : 10%
- Bonus : +Perception/2
- Multiplicateur : ×2 dégâts
- Formule : `chance_critique = 10 + (perception/2)`

**Calcul des dégâts** (💥) :
```
Dégâts bruts = Dégâts_base + (Attaque/2) + jet_d6
Dégâts finaux = max(1, Dégâts_bruts - (Défense/3))
```

**Récompenses** (🏆) :
- **Expérience** : Niveau_monstre × 20
- **Or** : Niveau_monstre × 15
- **Potion** : 30% de chance de drop

**Exemple de combat** :
```
!createplayer Aragorn humain 10 25 25 20 20 10
!createmonster Balrog vampire 12
!fight Aragorn Balrog
```

### 🤖 Client IRC (Nouveau)
- **Intégration complète** avec lua-irc-engine
- **Commandes IRC** pour contrôler le RPG
- **Bot IRC autonome** avec système de jeu
- **Réponses automatiques** aux commandes

### 💬 Système de Commandes Unifié
- **Commandes interactives** pour contrôler le RPG
- **Interface simple** : `createplayer`, `createmonster`, `roll`, `stats`, etc.
- **Intégration complète** avec le système d'agents

## Commandes Disponibles

### Commandes RPG (Console et IRC)

```lua
-- Créer un personnage (100 points max)
!createplayer <nom> <classe> <niveau> <int> <str> <dex> <end> <mag>
Exemple: !createplayer Gandalf mage 10 30 10 15 20 25

-- Créer un monstre
!createmonster <nom> <classe> <niveau>
Exemple: !createmonster Balrog vampire 12

-- Lancer un combat
!fight <joueur> <monstre>
Exemple: !fight Gandalf Balrog

-- Lancer des dés
!roll <nombre_de_dés>
Exemple: !roll 3

-- Afficher les statistiques
!stats <player/monster> <nom>
Exemple: !stats player Gandalf

-- Utiliser un objet
!use <type> <nom>
Exemple: !use potion Gandalf

-- Lister les classes disponibles
!listclasses

-- Aide au combat
!combathelp ou !fighthelp

-- Aide complète
!help
```

### Commandes IRC Spécifiques

- `!ping` - Tester la connexion au bot
- `!version` - Afficher la version du bot
- `!info` - Informations sur le bot

## Exemples d'Utilisation

### Créer un personnage Mage:
```lua
createplayer Gandalf mage 10 15 5 8 7 10
```

### Créer un monstre Vampire:
```lua
createmonster Dracula vampire 15
```

### Lancer 3 dés:
```lua
roll 3
-- Résultat: "3 + 5 + 2 = 10"
```

### Voir les statistiques:
```lua
stats player Gandalf
stats monster Dracula
```

### Obtenir de l'aide sur le combat:
```lua
combathelp
-- ou
fighthelp
-- Résultat: Affiche les mécaniques de combat détaillées
```

## Différences majeures entre C et Lua

1. **Gestion mémoire** : Lua utilise un garbage collector, pas besoin de `malloc`/`free`
2. **Structures** : Les structs C deviennent des tables Lua avec métatables
3. **Pointeurs** : Lua utilise des références automatiques
4. **Bibliothèques** : `libcurl` est remplacé par une bibliothèque HTTP Lua
5. **Sécurité** : Lua est plus sûr pour la manipulation de chaînes et mémoire
6. **Extensibilité** : Le système RPG est entièrement modulaire et extensible

## Architecture du Système RPG

```
GNU-AI RPG System
├── Agent System (existante)
│   ├── WebAgent (recherche web)
│   └── RPGAgent (nouveau)
├── RPG Core
│   ├── Character System
│   ├── Monster System
│   ├── Dice System
│   └── Class Definitions
└── Command Interface
    └── Unified Command System
```

## Extensibilité

Le système est conçu pour être facilement étendu :

### Ajouter de nouvelles classes de personnages:
1. Modifier `rpg/classes.lua`
2. Ajouter la nouvelle classe dans `character_classes`
3. Définir les attributs et sorts de base

### Ajouter de nouvelles classes de monstres:
1. Modifier `rpg/classes.lua`
2. Ajouter la nouvelle classe dans `monster_classes`
3. Définir les statistiques et capacités

### Ajouter de nouvelles commandes:
1. Modifier `rpg/commands.lua`
2. Ajouter la nouvelle fonction de commande
3. Mettre à jour la liste des commandes disponibles

## Notes

- Le code utilise l'API DuckDuckGo pour les recherches web
- La vérification SSL est désactivée pour simplifier (à activer en production)
- Le système RPG est entièrement intégré dans l'architecture d'agents existante
- Tous les composants sont modulaires et peuvent être utilisés indépendamment

## Intégration avec le Système d'Agents

L'agent RPG s'intègre parfaitement avec l'architecture existante :

```lua
-- Création de l'agent RPG
local rpg_agent = RPGAgent.create_rpg_agent()

-- Exécution de l'agent
rpg_agent.execute(rpg_agent.context)

-- Exécution de commandes spécifiques
local result = rpg_agent.execute_command("createplayer Gandalf mage 10", context)
```

Le système maintient la compatibilité complète avec les agents existants tout en ajoutant des fonctionnalités RPG puissantes.

## Prochaines Étapes Possibles

1. **Ajouter plus de classes** (Nain, Orc, Troll, etc.)
2. **Implémenter un système de combat** entre personnages et monstres
3. **Ajouter un système de quêtes** et d'aventures
4. **Intégrer une interface utilisateur** plus avancée
5. **Ajouter la persistance** des données (sauvegarde/chargement)
6. **Étendre le système de commandes** avec plus de fonctionnalités

🎮 **Le système RPG est maintenant pleinement opérationnel dans GNU-AI!**