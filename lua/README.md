# GNU-AI Lua Version

Conversion du projet GNU-AI de C vers Lua.

## Structure

- `agent.lua` - Système d'agents (équivalent de agent.h/agent.c)
- `web.lua` - Module de recherche web (équivalent de web.h/web.c) 
- `main.lua` - Programme principal (équivalent de main.c)

## Dépendances

Pour exécuter ce code Lua, vous aurez besoin de :

1. **Lua 5.1+** - Installé sur votre système
2. **Bibliothèque HTTP** - Une des options suivantes :
   - `luarocks install lua-resty-http` (recommandé, utilisé dans le code)
   - `luarocks install luasocket` (alternative)

## Installation

```bash
# Installer Lua si ce n'est pas déjà fait
sudo apt-get install lua5.1

# Installer luarocks (gestionnaire de paquets Lua)
sudo apt-get install luarocks

# Installer la bibliothèque HTTP
luarocks install lua-resty-http
```

## Exécution

```bash
cd lua
lua main.lua
```

## Différences majeures entre C et Lua

1. **Gestion mémoire** : Lua utilise un garbage collector, pas besoin de `malloc`/`free`
2. **Structures** : Les structs C deviennent des tables Lua avec métatables
3. **Pointeurs** : Lua utilise des références automatiques
4. **Bibliothèques** : `libcurl` est remplacé par une bibliothèque HTTP Lua
5. **Sécurité** : Lua est plus sûr pour la manipulation de chaînes et mémoire

## Notes

- Le code utilise l'API DuckDuckGo pour les recherches web
- La vérification SSL est désactivée pour simplifier (à activer en production)
- Le code est plus concis grâce aux caractéristiques de Lua