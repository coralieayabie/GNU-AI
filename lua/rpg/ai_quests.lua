-- rpg/ai_quests.lua - Génération de quêtes via AI
local json = require("dkjson")

local AIQuests = {}
AIQuests.__index = AIQuests

local QUEST_PROMPTS = {
    base = "Génère une quête pour un RPG fantasy niveau %d. Format JSON: " ..
           "{title:string, description:string, reward:{xp:number, gold:number}, steps:string[]}",
    for_player = "Génère une quête pour %s (niveau %d, classe %s). Format JSON: " ..
                 "{title:string, description:string, reward:{xp:number, gold:number}, steps:string[]}"
}

function AIQuests.new(ai_backend)
    return setmetatable({ai = ai_backend}, { __index = AIQuests })
end

function AIQuests:generate(level, player_name, player_class)
    level = level or 5
    local prompt = player_name and
        string.format(QUEST_PROMPTS.for_player, player_name, level, player_class or "aventurier") or
        string.format(QUEST_PROMPTS.base, level)

    local response = self.ai:query(prompt)
    if not response then
        return {
            title = "Quête aléatoire",
            description = "Explorez la région.",
            reward = {xp = level * 10, gold = level * 5},
            steps = {"Parlez au PNJ", "Complétez l'objectif"}
        }
    end

    local json_str = response:match("{.*}") or "{}"
    local success, quest = pcall(json.decode, json_str)
    if not success then
        return {
            title = "Quête de secours",
            description = "Aidez un villageois.",
            reward = {xp = level * 10, gold = level * 5},
            steps = {"Trouvez le PNJ", "Résolvez le problème"}
        }
    end

    return quest
end

return AIQuests

