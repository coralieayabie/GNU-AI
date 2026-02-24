local socket = require("socket")
local config = require("config")
local RPGAgent = require("rpg.rpg_agent")

local IRCBot = {}
IRCBot.__index = IRCBot

function IRCBot.new()
    local self = setmetatable({}, { __index = IRCBot })
    self.state = {connected = false, socket = nil, last_ping = 0}
    self.rpg_agent = RPGAgent.create_rpg_agent()
    self.rpg_context = self.rpg_agent.context
    return self
end

function IRCBot:connect()
    print("🔌 Connexion à " .. config.irc.server .. "...")
    local sock = socket.tcp()
    sock:settimeout(30)

    local success, err = sock:connect(config.irc.server, config.irc.port)
    if not success then
        print("❌ Erreur: " .. tostring(err))
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
    if not success then print("❌ Erreur d'envoi: " .. tostring(err)) end
    return success
end

function IRCBot:receive()
    if not self.state.socket then return nil, "Non connecté" end
    local line, err = self.state.socket:receive()
    if not line then return nil, err end
    return line:gsub("\r?\n$", "")
end

function IRCBot:process_command(sender, command)
    return self.rpg_agent:execute_command(command, self.rpg_context)
end

function IRCBot:handle_irc_command(sender, message)
    if not message or message == "" then return end

    if message:match("^!%w+") then
        local response = self:process_command(sender, message)
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
        return
    end

    if message:lower() == "!ping" then
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": Pong!")
    elseif message:lower():match("^!ai ") then
        if self.rpg_context.ai then
            local prompt = message:sub(5)
            local response = self.rpg_context.ai:get_response(prompt)
            self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
        else
            self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": L'AI est désactivée.")
        end
    end
end

function IRCBot:run()
    if not self:connect() then return false end

    print("🔄 Bot IRC en cours d'exécution. Ctrl+C pour quitter.")

    while self.state.connected do
        local line, err = self:receive()

        if not line then
            if err == "timeout" then
                if socket.gettime() - self.state.last_ping > 60 then
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
    end
end

return IRCBot

