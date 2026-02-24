local json = require("dkjson")

local AIMonsters = {}
AIMonsters.__index = AIMonsters

local MONSTER_PROMPTS = {
    base = "Génère un monstre pour un RPG fantasy niveau %d. Format JSON: " ..
           "{name: string, class: string, level: number, description: string, health: number, damage: number, armor: number, loot: string[]}.",
    from_class = "Génère un monstre de classe '%s' niveau %d. Format JSON: " ..
                 "{name: string, description: string, health: number, damage: number, armor: number, loot: string[]}.",
}

function AIMonsters.new(ai_backend)
    return setmetatable({ai = ai_backend}, { __index = AIMonsters })
end

function AIMonsters:generate_random(level)
    level = level or 5
    local prompt = string.format(MONSTER_PROMPTS.base, level)
    local response = self.ai:query(prompt)
    if not response then return nil end

    local json_str = response:match("{.*}") or "{}"
    local success, monster = pcall(json.decode, json_str)
    if not success then return nil end

    monster.level = level
    monster.health = monster.health or (level * 20)
    monster.damage = monster.damage or (level * 3)
    monster.armor = monster.armor or 1
    monster.loot = monster.loot or {"Pièces d'or"}

    return monster
end

function AIMonsters:generate_from_class(class_name, level)
    level = level or 5
    local prompt = string.format(MONSTER_PROMPTS.from_class, class_name, level)
    local response = self.ai:query(prompt)
    if not response then return nil end

    local json_str = response:match("{.*}") or "{}"
    local success, monster = pcall(json.decode, json_str)
    if not success then return nil end

    monster.class = class_name
    monster.level = level
    return monster
end

return AIMonsters

