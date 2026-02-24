-- Bot IRC complet pour GNU-AI
local socket = require("socket")
local config = require("config")
local RPGAgent = require("rpg.rpg_agent")

local IRCBot = {}
IRCBot.__index = IRCBot

function IRCBot.new()
    local self = setmetatable({}, { __index = IRCBot })
    self.state = {
        connected = false,
        socket = nil,
        last_ping = 0,
        last_command_time = 0,
        command_cooldown = 1
    }
    self.rpg_agent = RPGAgent.create_rpg_agent()
    self.rpg_context = self.rpg_agent.context
    return self
end

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

    self:send("NICK " .. config.irc.nickname)
    self:send("USER " .. config.irc.username .. " 0 * :" .. config.irc.realname)
    self:send("JOIN " .. config.irc.default_channel)

    print("✅ Connecté à " .. config.irc.server)
    return true
end

function IRCBot:send(message)
    if not self.state.socket then return false end
    local success, err = self.state.socket:send(message .. "\r\n")
    if not success then
        print("❌ Erreur d'envoi: " .. tostring(err))
        return false
    end
    return true
end

function IRCBot:receive()
    if not self.state.socket then return nil, "Non connecté" end
    local line, err = self.state.socket:receive()
    if not line then return nil, err end
    return line:gsub("\r?\n$", "")
end

function IRCBot:process_command(sender, command)
    local current_time = socket.gettime()
    if current_time - self.state.last_command_time < self.state.command_cooldown then
        return "⏳ Veuillez attendre avant la prochaine commande."
    end
    self.state.last_command_time = current_time

    return self.rpg_agent:execute_command(command, self.rpg_context)
end

function IRCBot:handle_irc_command(sender, message)
    if not message or message == "" then return end

    -- Commandes RPG (commencent par !)
    if message:match("^!%w+") then
        local response = self:process_command(sender, message)

        -- Gestion spéciale pour l'aide multi-lignes
        if message:lower():match("^!help") then
            for line in response:gmatch("[^\n]+") do
                self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. line)
                socket.sleep(0.3)
            end
        else
            self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
        end
        return
    end

    -- Commandes spéciales
    if message:lower() == "!ping" then
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": 🏓 Pong!")
    end
end

function IRCBot:run()
    if not self:connect() then return false end

    print("🔄 Bot IRC en cours d'exécution. Ctrl+C pour quitter.")

    while self.state.connected do
        local line, err = self:receive()

        if not line then
            if err == "timeout" then
                if socket.gettime() - self.state.last_ping > config.irc.ping_interval then
                    self:send("PING :" .. config.irc.server)
                    self.state.last_ping = socket.gettime()
                end
            else
                print("❌ Déconnecté: " .. tostring(err))
                break
            end
        else
            print("← " .. line)

            local sender, channel, msg = line:match("^:(.-)!.- PRIVMSG (.-) :(.+)")
            if sender and channel and msg then
                self:handle_irc_command(sender, msg)
            end

            if line:match("^PING :") then
                local ping_target = line:match("^PING :(.+)")
                self:send("PONG :" .. ping_target)
            end
        end
        socket.sleep(0.1)
    end

    self:disconnect()
    return true
end

function IRCBot:disconnect()
    if self.state.socket then
        self:send("QUIT :GNU-AI Bot déconnecté")
        self.state.socket:close()
        self.state.socket = nil
        self.state.connected = false
    end
end

return IRCBot

