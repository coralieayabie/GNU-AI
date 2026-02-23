-- irc_bot.lua - Ajout des commandes AI
local RPGAgent = require("rpg.rpg_agent")

-- Dans handle_irc_command:
function IRCBot:handle_irc_command(sender, message)
    -- Commandes RPG existantes
    if message:match("^!%w+") then
        local response = self:process_command(sender, message)
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
        return
    end

    -- Nouvelle commande: !ai
    if message:lower():match("^!ai ") then
        local prompt = message:sub(5)
        if self.rpg_context.ai then
            local response = self.rpg_context.ai:get_response(prompt)
            self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
        else
            self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": L'AI est désactivée.")
        end
    end
end

