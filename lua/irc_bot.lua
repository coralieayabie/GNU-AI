-- irc_bot.lua - Bot IRC complet pour GNU-AI avec intégration RPG et AI
local socket = require("socket")
local config = require("config")
local RPGAgent = require("rpg.rpg_agent")

local IRCBot = {}
IRCBot.__index = IRCBot

-- État initial du bot
local function create_initial_state()
    return {
        connected = false,
        socket = nil,
        last_ping = 0,
        last_command_time = 0,
        command_cooldown = 1  -- 1 seconde entre les commandes
    }
end

-- Constructeur
function IRCBot.new()
    local self = setmetatable({}, { __index = IRCBot })
    self.state = create_initial_state()
    self.rpg_agent = RPGAgent.create_rpg_agent()
    self.rpg_context = self.rpg_agent.context
    return self
end

-- Connexion au serveur IRC
function IRCBot:connect()
    print(string.format("🔌 Connexion à %s:%d...", config.irc.server, config.irc.port))

    local sock = socket.tcp()
    sock:settimeout(config.irc.connection_timeout or 30)

    local success, err = sock:connect(config.irc.server, config.irc.port)
    if not success then
        print("❌ Erreur de connexion: " .. tostring(err))
        return false
    end

    self.state.socket = sock
    self.state.connected = true
    self.state.last_ping = socket.gettime()

    -- Identification IRC
    self:send("NICK " .. config.irc.nickname)
    self:send("USER " .. config.irc.username .. " 0 * :" .. config.irc.realname)

    -- Rejoindre le canal
    self:send("JOIN " .. config.irc.default_channel)

    print("✅ Connecté à " .. config.irc.server)
    print("📝 Canal rejoint: " .. config.irc.default_channel)
    return true
end

-- Envoyer une commande IRC
function IRCBot:send(message)
    if not self.state.socket then return false end
    local success, err = self.state.socket:send(message .. "\r\n")
    if not success then
        print("❌ Erreur d'envoi: " .. tostring(err))
        return false
    end
    return true
end

-- Recevoir un message
function IRCBot:receive()
    if not self.state.socket then return nil, "Non connecté" end
    local line, err = self.state.socket:receive()
    if not line then return nil, err end
    return line:gsub("\r?\n\$", "")
end

-- Traiter une commande RPG
function IRCBot:process_command(sender, command)
    -- Vérifier le cooldown pour éviter le flood
    local current_time = socket.gettime()
    if current_time - self.state.last_command_time < self.state.command_cooldown then
        return "⏳ Veuillez attendre " ..
               string.format("%.1f", self.state.command_cooldown - (current_time - self.state.last_command_time)) ..
               " secondes avant la prochaine commande."
    end
    self.state.last_command_time = current_time

    return self.rpg_agent:execute_command(command, self.rpg_context)
end

-- Gérer les commandes IRC
function IRCBot:handle_irc_command(sender, message)
    if not message or message == "" then return end

    -- Commandes RPG (commencent par !)
    if message:match("^!%w+") then
        local response = self:process_command(sender, message)

        -- Pour les commandes multi-lignes comme help, envoyer ligne par ligne
        if message:lower():match("^!help") or message:lower():match("^!aide") then
            for line in response:gmatch("[^\n]+") do
                self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. line)
                socket.sleep(0.3)  -- Délai pour éviter le flood
            end
        else
            self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
        end
        return
    end

    -- Commandes spéciales
    if message:lower() == "!ping" then
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": 🏓 Pong!")
        return
    elseif message:lower():match("^!ai ") then
        if self.rpg_context.ai then
            local prompt = message:sub(5)  -- Enlever "!ai "
            local response = self.rpg_context.ai:get_response(
                "Réponds à cette question sur un RPG en Lua, en français, de manière concise et utile: " .. prompt
            )
            -- Envoyer la réponse en plusieurs parties si trop longue
            if #response > 300 then
                for part in response:gmatch(".{1,300}") do
                    self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. part)
                    socket.sleep(0.4)
                end
            else
                self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
            end
        else
            self:send("PRIVMSG " .. config.irc.default_channel .. " 

