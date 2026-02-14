# 🎮 Système de Combat Avancé GNU-AI

## 📖 Introduction

Ce document décrit le système de combat avancé avec choix d'actions et de nombre de dés, permettant aux joueurs de contrôler finement leurs stratégies de combat.

## 🎯 Fonctionnalités Principales

### 1. Choix du Nombre de Dés 🎲

- **1 dé** : Combat simple et prévisible
- **2-3 dés** : Équilibre entre variété et contrôle
- **4-5 dés** : Grande variété et résultats imprévisibles

**Commande** : `!setdice <combat_id> <nombre>`

**Exemple** :
```
!setdice combat_1234567890 3
// Réponse: ✅ Nombre de dés défini à 3
```

### 2. Sélection d'Actions ⚔️

Quatre types d'actions disponibles :

- **Attaque** : Action offensive standard
- **Défense** : Augmente la défense pour le tour (réduit les dégâts reçus)
- **Esquive** : Augmente l'esquive pour le tour (chance d'éviter les attaques)
- **Magie** : Lance un sort aléatoire selon la classe du personnage

**Commande** : `!setaction <combat_id> <cible> <action>`

**Exemples** :
```
!setaction combat_1234567890 joueur magie
!setaction combat_1234567890 monstre défense
```

### 3. Gestion des Combats 📋

**Liste des combats actifs** :
```
!listcombats
// Réponse: Combats actifs: combat_1234567890: Gandalf vs Dragon Noir (Tour 2)
```

**Démarrage d'un combat** :
```
!fight Gandalf DragonNoir
// Réponse: 🔥 COMBAT COMMENCÉ: Gandalf (Lvl 15) vs Dragon Noir (Lvl 12) [ID: combat_1234567890]
```

## 🎮 Exemple de Session Complète

```
[14:30] <User1> !fight Gandalf DragonNoir
[14:30] <GNU_AI_Bot2> 🔥 COMBAT COMMENCÉ: Gandalf (Lvl 15) vs Dragon Noir (Lvl 12) [ID: combat_1234567890]
[14:30] <GNU_AI_Bot2> === TOUR 1 ===
[14:30] <GNU_AI_Bot2> 🔹 Tour de Gandalf
[14:30] <GNU_AI_Bot2> 💥 Gandalf inflige 25 dégâts à Dragon Noir! (Dés: 3+4=7)

[14:30] <User2> !setdice combat_1234567890 3
[14:30] <GNU_AI_Bot2> ✅ Nombre de dés défini à 3

[14:30] <User1> !setaction combat_1234567890 joueur magie
[14:30] <GNU_AI_Bot2> ⚔️ Action du joueur: magie

[14:30] <GNU_AI_Bot2> === TOUR 2 ===
[14:30] <GNU_AI_Bot2> 🔹 Tour de Gandalf
[14:30] <GNU_AI_Bot2> ✨ Gandalf lance un sort!
[14:30] <GNU_AI_Bot2> 💥 Gandalf inflige 45 dégâts magiques à Dragon Noir! (Dés: 6+5+4=15)

[14:30] <User2> !listcombats
[14:30] <GNU_AI_Bot2> Combats actifs: combat_1234567890: Gandalf vs Dragon Noir (Tour 2)
```

## 🎯 Stratégies Recommandées

### 1. Stratégie Offensive 💥
**Objectif** : Maximiser les dégâts infligés
**Configuration** :
- Nombre de dés: 3-4
- Actions: Toujours attaquer
**Avantages** :
- Élimine rapidement les monstres
- Bonne pour les personnages forts
**Inconvénients** :
- Reçoit plus de dégâts

### 2. Stratégie Défensive 🛡️
**Objectif** : Minimiser les dégâts reçus
**Configuration** :
- Nombre de dés: 1-2
- Actions: Alterner défense et attaque
**Avantages** :
- Survit plus longtemps
- Bonne contre les monstres puissants
**Inconvénients** :
- Combat plus long
- Moins de dégâts infligés

### 3. Stratégie Évasive 🏃
**Objectif** : Éviter les attaques ennemies
**Configuration** :
- Nombre de dés: 2
- Actions: Esquive contre les attaques puissantes
**Avantages** :
- Évite complètement les dégâts
- Bonne pour les personnages agiles
**Inconvénients** :
- Moins efficace contre les monstres lents

### 4. Stratégie Magique ✨
**Objectif** : Utiliser la puissance des sorts
**Configuration** :
- Nombre de dés: 2-3
- Actions: Magie avec les mages
**Avantages** :
- Dégâts élevés
- Effets spéciaux possibles
**Inconvénients** :
- Dépend de la classe du personnage
- Imprévisible

## 📊 Mécaniques de Combat

### Calcul des Dégâts
```
Dégâts = Dégâts_base + (Attaque/2) + jet_de_dés - (Défense/3)
```

### Esquive
- **Chance de base** : 15%
- **Bonus** : +Dextérité/2 ou +Furtivité
- **Formule** : `chance_esquive = 15 + (dexterité/2)`

### Blocage
- **Chance de base** : 20%
- **Bonus** : +Endurance/3 ou +Défense
- **Réduction** : 70% des dégâts
- **Formule** : `chance_blocage = 20 + (endurance/3)`

### Coups Critiques
- **Chance de base** : 10%
- **Bonus** : +Perception/2
- **Multiplicateur** : ×2 dégâts
- **Formule** : `chance_critique = 10 + (perception/2)`

## 🔧 Commandes Récapitulatives

| Commande | Description | Exemple |
|----------|-------------|---------|
| `!fight <joueur> <monstre>` | Démarrer un combat | `!fight Gandalf Dragon` |
| `!setdice <id> <nombre>` | Changer le nombre de dés | `!setdice combat_123 3` |
| `!setaction <id> <cible> <action>` | Changer l'action | `!setaction combat_123 joueur magie` |
| `!listcombats` | Lister les combats actifs | `!listcombats` |
| `!combathelp` | Aide sur le combat | `!combathelp` |

## 📈 Classes et Attributs

### Classes de Personnages
- **Mage** : Haute intelligence et magie, bonne pour les sorts
- **Humain** : Équilibré, bon pour toutes les stratégies
- **Hobbit** : Haute dextérité, bon pour l'esquive
- **Elfe** : Bon en attaque et esquive

### Attributs Importants
- **Intelligence** : Affecte la magie et la perception
- **Force** : Affecte l'attaque physique
- **Dextérité** : Affecte l'esquive et la furtivité
- **Endurance** : Affecte la santé et la défense
- **Magie** : Affecte les sorts et la résistance magique

## 🎮 Intégration IRC

Tous les combats sont diffusés en direct sur le canal IRC avec :
- Annonce du début du combat avec ID unique
- Logs détaillés de chaque tour
- Affichage des actions et résultats
- Résumé final à la fin du combat

## 💡 Conseils Avancés

1. **Adaptez votre stratégie** selon le type de monstre
2. **Utilisez la magie** avec les mages pour des dégâts élevés
3. **La défense** est utile contre les monstres puissants
4. **L'esquive** fonctionne bien contre les monstres rapides
5. **Expérimentez** avec différents nombres de dés pour trouver votre style

## 🔒 Limitations

- Maximum 5 dés par attaque
- Les combats expirent après la fin (nettoyage automatique)
- Les actions spéciales sont réinitialisées chaque tour
- Un seul combat actif par joueur à la fois

## 🚀 Conclusion

Le système de combat avancé offre une expérience de jeu riche et stratégique, permettant aux joueurs de contrôler finement leurs actions et de développer des tactiques sophistiquées. Avec l'intégration IRC, les combats deviennent également une expérience sociale et interactive pour toute la communauté.

🎮 Bon jeu et que la meilleure stratégie gagne ! ⚔️🎲
