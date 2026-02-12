-- dice.lua - Système de dés RPG pour GNU-AI
-- Adapté du système IRC RPG

local Dice = {}

-- Lance un dé à 6 faces
function Dice.roll_d6()
    return math.random(1, 6)
end

-- Lance plusieurs dés à 6 faces
function Dice.roll_dice(num_dice)
    local results = {}
    local total = 0
    
    num_dice = math.max(1, math.min(num_dice or 1, 10))  -- Limite à 10 dés max
    
    for i = 1, num_dice do
        local roll = Dice.roll_d6()
        table.insert(results, roll)
        total = total + roll
    end
    
    return results, total
end

-- Formate les résultats des dés
function Dice.format_roll(results, total)
    return table.concat(results, " + ") .. " = " .. total
end

-- Lance des dés et retourne un résultat formaté
function Dice.roll_and_format(num_dice)
    local results, total = Dice.roll_dice(num_dice)
    return Dice.format_roll(results, total)
end

return Dice