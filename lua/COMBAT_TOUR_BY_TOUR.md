# 🎮 Système de Combat Tour par Tour GNU-AI

## 📖 Introduction

Ce document décrit le système de combat tour par tour simplifié, permettant aux joueurs de choisir leurs actions et le nombre de dés à chaque tour sans avoir à gérer des IDs complexes.

## 🎯 Fonctionnalités Principales

### 1. Choix du Nombre de Dés à Chaque Tour 🎲

Contrairement à l'ancien système, les joueurs peuvent maintenant définir le nombre de dés pour leur **prochain tour** sans avoir à spécifier un ID de combat.

**Commande** : `!setdice <nombre>`

**Exemple** :
```
!setdice 3
// Réponse: ✅ Nombre de dés défini à 3 pour le prochain tour
```

**Options** :
- `1 dé` : Combat simple et prévisible
- `2-3 dés` : Équilibre entre variété et contrôle
- `4-5 dés` : Grande variété et résultats imprévisibles

### 2. Sélection d'Actions Sans IDs ⚔️

Les joueurs peuvent choisir l'action pour leur personnage ou le monstre pour le prochain tour.

**Commande** : `!setaction <joueur/monstre> <action>`

**Exemples** :
```
!setaction joueur magie
!setaction monstre défense
```

**Actions disponibles** :
- **Attaque** : Action offensive standard
- **Défense** : Augmente la défense pour le tour (réduit les dégâts reçus)
- **Esquive** : Augmente l'esquive pour le tour (chance d'éviter les attaques)
- **Magie** : Lance un sort aléatoire selon la classe du personnage

### 3. Workflow Simplifié 📋

**Ancien système** (avec IDs) :
```
!fight Gandalf Orc                // Démarre le combat
!listcombats                      // Trouver l'ID
!setdice combat_1234567890 3      // Changer les dés
!setaction combat_1234567890 joueur magie  // Changer l'action
```

**Nouveau système** (sans IDs) :
```
!fight Gandalf Orc                // Démarre le combat
!setdice 3                        // Prépare 3 dés pour le prochain tour
!setaction joueur magie           // Prépare l'action magie pour le prochain tour
```

## 🎮 Exemple de Session Complète

```
[14:30] <User1> !fight Gandalf Orc
[14:30] <GNU_AI_Bot2> 🔥 COMBAT COMMENCÉ: Gandalf (Lvl 15) vs Orc (Lvl 8)
[14:30] <GNU_AI_Bot2> === TOUR 1 ===
[14:30] <GNU_AI_Bot2> 🔹 Tour de Gandalf
[14:30] <GNU_AI_Bot2> 💥 Gandalf inflige 25 dégâts à Orc! (Dés: 4)

[14:30] <User1> !setdice 3
[14:30] <GNU_AI_Bot2> ✅ Nombre de dés défini à 3 pour le prochain tour

[14:30] <User1> !setaction joueur magie
[14:30] <GNU_AI_Bot2> ⚔️ Action du joueur: magie pour le prochain tour

[14:30] <GNU_AI_Bot2> === TOUR 2 ===
[14:30] <GNU_AI_Bot2> 🔹 Tour de Gandalf
[14:30] <GNU_AI_Bot2> ✨ Gandalf lance un sort!
[14:30] <GNU_AI_Bot2> 💥 Gandalf inflige 45 dégâts magiques à Orc! (Dés: 6+5+4=15)

[14:30] <User1> !setaction joueur défense
[14:30] <GNU_AI_Bot2> ⚔️ Action du joueur: défense pour le prochain tour

[14:30] <GNU_AI_Bot2> === TOUR 3 ===
[14:30] <GNU_AI_Bot2> 🔹 Tour de Gandalf
[14:30] <GNU_AI_Bot2> 🛡️ Gandalf se prépare à défendre!
[14:30] <GNU_AI_Bot2> ⚡ Orc attaque mais Gandalf se défend!
```

## 🎯 Avantages du Nouveau Système

### 1. **Simplicité** 🎯
- Plus besoin de mémoriser ou de gérer des IDs de combat
- Commandes plus courtes et plus intuitives
- Moins d'erreurs possibles

### 2. **Flexibilité** 🔄
- Changement d'actions et de dés à chaque tour
- Pas besoin de planifier à l'avance
- Adaptation facile aux situations

### 3. **Expérience Utilisateur** 💬
- Moins de commandes à retenir
- Flow de jeu plus naturel
- Meilleure intégration avec les chats IRC

### 4. **Apprentissage** 📚
- Plus facile pour les nouveaux joueurs
- Moins de documentation à lire
- Essais et erreurs encouragés

## 📊 Stratégies Recommandées

### 1. Stratégie Adaptative 🎯
**Objectif** : S'adapter à la situation
**Tactique** :
- Commencer avec 2 dés (équilibré)
- Passer à 3 dés si le monstre est résistant
- Utiliser la magie avec les mages
- La défense contre les attaques puissantes

### 2. Stratégie Aggressive 💥
**Objectif** : Éliminer rapidement
**Tactique** :
- Toujours utiliser 3-4 dés
- Attaquer à chaque tour
- Ignorer la défense
**Pour** : Guerriers et personnages forts

### 3. Stratégie Défensive 🛡️
**Objectif** : Survivre et user l'ennemi
**Tactique** :
- Alterner attaque et défense
- Utiliser 1-2 dés pour contrôler les dégâts
- Esquiver contre les monstres rapides
**Pour** : Personnages fragiles ou contre les boss

### 4. Stratégie Magique ✨
**Objectif** : Maximiser les dégâts spéciaux
**Tactique** :
- Utiliser la magie à chaque tour avec les mages
- 2-3 dés pour équilibrer puissance et contrôle
- Attaquer normalement si la magie échoue
**Pour** : Mages et personnages magiques

## 🔧 Commandes Récapitulatives

| Commande | Description | Exemple |
|----------|-------------|---------|
| `!fight <joueur> <monstre>` | Démarrer un combat | `!fight Gandalf Orc` |
| `!setdice <nombre>` | Définir le nombre de dés (1-5) | `!setdice 3` |
| `!setaction <cible> <action>` | Définir l'action | `!setaction joueur magie` |
| `!combathelp` | Aide sur le combat | `!combathelp` |

**Cibles valides** : `joueur` ou `monstre`
**Actions valides** : `attaque`, `défense`, `esquive`, `magie`

## 📈 Mécaniques de Combat

### Calcul des Dégâts
```
Dégâts = Dégâts_base + (Attaque/2) + jet_de_dés - (Défense/3)
```

### Esquive
- **Chance de base** : 15%
- **Bonus** : +Dextérité/2 ou +Furtivité
- **Formule** : `chance_esquive = 15 + (dexterité/2)`

### Blocage (Défense)
- **Chance de base** : 20%
- **Bonus** : +Endurance/3 ou +Défense
- **Réduction** : 70% des dégâts
- **Formule** : `chance_blocage = 20 + (endurance/3)`

### Coups Critiques
- **Chance de base** : 10%
- **Bonus** : +Perception/2
- **Multiplicateur** : ×2 dégâts
- **Formule** : `chance_critique = 10 + (perception/2)`

## 🎮 Intégration IRC

Tous les combats sont diffusés en direct sur le canal IRC avec :
- Annonce du début du combat
- Logs détaillés de chaque tour
- Affichage des actions choisies
- Résumé final à la fin du combat

## 💡 Conseils Avancés

1. **Expérimentez** avec différents nombres de dés pour trouver votre style
2. **Adaptez votre stratégie** selon le type de monstre
3. **Utilisez la magie** avec les mages pour des dégâts élevés
4. **La défense** est utile contre les monstres puissants
5. **L'esquive** fonctionne bien contre les monstres rapides
6. **Observez les patterns** des monstres pour anticiper
7. **Variez vos actions** pour éviter d'être prévisible

## 🔒 Limitations

- Les paramètres (dés et actions) ne s'appliquent qu'au **prochain tour**
- Maximum 5 dés par attaque
- Les actions sont réinitialisées après chaque tour
- Un seul jeu de paramètres à la fois

## 🚀 Conclusion

Le nouveau système de combat tour par tour offre une expérience de jeu plus simple, plus intuitive et plus flexible. Sans la complexité des IDs, les joueurs peuvent se concentrer sur la stratégie et le plaisir du jeu.

🎮 Bon jeu et que la meilleure stratégie gagne ! ⚔️🎲
