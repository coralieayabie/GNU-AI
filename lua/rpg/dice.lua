-- Système de dés RPG
local Dice = {}

function Dice.roll_d6()
    return math.random(1, 6)
end

function Dice.roll_dice(num_dice)
    local results = {}
    local total = 0
    num_dice = math.max(1, math.min(num_dice or 1, 10))

    for i = 1, num_dice do
        local roll = Dice.roll_d6()
        table.insert(results, roll)
        total = total + roll
    end

    return results, total
end

function Dice.format_roll(results, total)
    return table.concat(results, " + ") .. " = " .. total
end

function Dice.roll_and_format(num_dice)
    local results, total = Dice.roll_dice(num_dice)
    return Dice.format_roll(results, total)
end

return Dice

